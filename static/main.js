$(function () { 
        $('#first').on('click', function () {
        var div = document.getElementById("first_div");
        setTimeout(function(){ div.style.display = "none"; }, 600);
    })
}),

$(function () {
    $('#predict').on('click', function () {    
        var form_data = new FormData();

        form_data.append('user_id', document.getElementById('user_id').value);
        form_data.append('song_name', document.getElementById('song_id').value);
        form_data.append('reg_date', $('#reg_date').val());
        form_data.append('exp_date', $('#exp_date').val());
        form_data.append('age', document.getElementById('age').value);
        form_data.append('genre', $('#select_genre').val());
        form_data.append('reg_mode', $('#select_reg_mode').val());
        form_data.append('gender', $('#select_gender').val());
        form_data.append('city', $('#select_city').val());
        form_data.append('language', $('#select_lang').val());
        form_data.append('artist_name', $('#select_artist').val());
        form_data.append('source_system_tab', $('#select_source_system_tab').val());
        form_data.append('source_screen_name', $('#select_source_screen_name').val());
        form_data.append('source_type', $('#select_source_type').val());
        
        $.ajax({
            url: '/predict',
            dataType: 'json',
            cache: false,
            contentType: false,
            processData: false,
            type: "POST",
            data: form_data,
            success: function(response) { 
                output = response['output'];
                console.log(output);
                document.getElementById("first_div").style.display = "block";
                document.getElementById("text").innerHTML = 'It is '+output*100+ ' % chance that user will listen the song repeatedly if he has used the following method for listening the song';
                document.body.scrollTop = 0;
                document.documentElement.scrollTop = 0;
            },
            error: function(response) {
                console.log('error in  predict');
                console.log(response);
                document.getElementById("first_div").style.display = "block";
                document.getElementById("text").innerHTML = 'something went wrong please check whether all input fields are correctly filled';
                document.body.scrollTop = 0;
                document.documentElement.scrollTop = 0;
            }
        });
    });
}),


$(document).ready(function() {
    
    $.ajax({
        url: '/load_embedding',
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        type: "POST",
        success: function(response) {
            console.log(response);
            var song_id = response['song'];
            var x = document.getElementById("song_id");
            
            for (i = 0; i < 1000; i++) {
                var option = document.createElement("option");
                option.text = song_id[i];
                x.add(option);
            }

            var user_id = response['user'];
            var x = document.getElementById("user_id");
            var option = document.createElement("option");
            for (i = 0; i < 1000; i++) {
                var option = document.createElement("option");
                option.text = user_id[i];
                x.add(option);
            }
        },
        error: function(response) {
            console.log('error in  embedding');
            console.log(response);
        }
     });
}),

$(document).ready(function() {
    $.ajax({
        url: '/load_artist',
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        type: "GET",
        success: function(response) {
            console.log(response);
            var artist = response['artist'];
            var x = document.getElementById("select_artist");
            
            for (i = 0; i < 1000; i++) {
                var option = document.createElement("option");
                option.text = artist[i];
                x.add(option);
            }
        },
        error: function(response) {
            console.log('error in  artist');
            console.log(response);
        }
     });
});