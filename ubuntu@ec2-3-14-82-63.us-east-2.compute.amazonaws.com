from flask import Flask, render_template, flash, redirect, url_for, request, jsonify
from werkzeug.utils import secure_filename
import numpy as np
import os
import json
import pandas as pd
import datetime
import pickle

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'static/uploads/'
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'

artist = pd.read_csv('model/Data/artist_count_id.csv', index_col = 0)
user = pd.read_csv('model/Data/user_embedding.csv', index_col = 0)
song = pd.read_csv('model/Data/song_count_name_emb.csv', index_col = 0)

base_models = []
for i in range(20):
    base_models.append(pickle.load(open('model/weights/base_model'+str(i+1)+'.pickle', 'rb')))
meta_model = pickle.load(open('model/weights/meta_model.pickle', 'rb'))



@app.context_processor
def override_url_for():
    return dict(url_for=dated_url_for)

def dated_url_for(endpoint, **values):
    if endpoint == 'static':
        filename = values.get('filename', None)
        if filename:
            file_path = os.path.join(app.root_path,
                                 endpoint, filename)
            values['q'] = int(os.stat(file_path).st_mtime)
    return url_for(endpoint, **values)

@app.route('/')
def upload_form():
    print('in upload_form')
    return render_template('main.html')

@app.route('/load_embedding', methods=['POST'])
def load_emb():
    print('inside embedding')
    return jsonify({
        'user' : list(user['msno'].values)[:1000],
        'song' : list(song['name'].values)[:1000]
    })

@app.route('/load_artist', methods=['GET'])
def load_artist():
    print('inside artist')
    return jsonify({
        'artist' : list(artist['artist_name'].values)[:1000]
    })

@app.route('/predict', methods=['POST'])
def predict():
    print('inside predict')

    user_emb = list(user[user['msno'] == request.form['user_id']].values[0][1:].astype(float))
    song_emb = list(song[song['name'] == request.form['song_name']].values[0][4:].astype(float))
    date = request.form['reg_date'].split('-')
    reg_yr = int(date[0])
    reg_mon = int(date[1])
    reg_day = int(date[2])
    date = request.form['exp_date'].split('-')
    exp_yr = int(date[0])
    exp_mon = int(date[1])
    exp_day = int(date[2])
    age = int(request.form['age'])
    song_length = 32
    genre = int(request.form['genre'])
    
    ##Artist Name
    artist_name = request.form['artist_name']
    artist_id = artist[artist_name == artist['artist_name']]['Id']

    ##membership duration
    x = datetime.date(reg_yr, reg_mon, reg_day)
    y = datetime.date(exp_yr, exp_mon, exp_day)
    z = y-x
    membership_duration = z.days

    ## Source system tab
    tab = request.form['source_system_tab']
    map_source_tab = {'discover' : 0,'explore':1,'listen with':2,'my library':3,'notification':4,'radio':5,'search':6,'settings':7}
    source_tab = [0, 0, 0, 0, 0, 0, 0, 0]
    source_tab[map_source_tab[tab.lower()]] = 1

    ##Source Screen Name
    screen = request.form['source_screen_name']
    map_source_screen = {'album more' :0, 'artist more':1, 'concert':2, 'discover chart':3, 'discover feature':4, 'discover genre':5, 'discover new':6, 'explore':7,
                         'local playlist more':8, 'my library':9, 'my library search':10, 'online playlist more':11, 'others profile more':12, 'payment':13, 'radio':14, 
                         'search':15, 'search home':16, 'search trends':17, 'self profile more':18, 'unknown':19}
    source_screen = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    source_screen[map_source_screen[screen.lower()]] = 1

    ##Source Type
    type_ = request.form['source_type']
    map_source_type = {'album': 0, 'artist': 1, 'listen with': 2, 'local library': 3, 'local playlist': 4, 'my daily playlist': 5, 'online playlist': 6, 
                        'radio': 7, 'song': 8, 'song based playlist': 9, 'top hits for artist': 10, 'topic article playlist': 11}
    source_type = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    source_type[map_source_type[type_.lower()]] = 1

    ##gender
    gen = request.form['gender']
    map_gender = {'female': 0, 'male':1}
    gender = [0, 0]
    gender[map_gender[gen.lower()]] = 1
    emn = user_emb + song_emb
    inp = [age, song_length, genre, artist_id] + user_emb + song_emb+[exp_yr, exp_mon, exp_day, reg_yr, reg_mon, reg_day, membership_duration, np.log(12)]+source_tab + source_screen+source_type+ gender
    pred = predict(inp)
    print(pred)
    return jsonify({
        'output' : round(float(pred[0][1]), 1)
    })

def predict(inp):
    predictions = []
    for base_model in base_models:
        pred = base_model.predict_proba([inp])[:, 1].reshape(-1, 1)
        predictions.append(pred)
    predictions = np.array(predictions).T
    predictions = predictions.reshape(-1, len(base_models))
    y_pred = meta_model.predict_proba(predictions)
    return y_pred
if __name__ == "__main__":
    app.run(debug = True, port = 5500)