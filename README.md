# KKBox-Music-Recommendation-System
Music Recommendation system is all about recommending the songs which the user like based on their previous activities like searches, previously listened songs, etc. There are many techniques for building a recommendation like Collaborative Filtering, Content Based filtering, Hybrid methods (Combining both Content Based and Collaborative Filtering methods). 

In this challenge we have to build a recommendation system that can predict whether a user will listen to a song again within one month after the user's very first observable listening event in KKBox application. If the user did not listen to the song again within one month, the target variable will be 0, and 1 otherwise.  
# Business Problem : 
This can helps KKBox company to recommend songs to users, to apply rating to songs, to determine the taste in songs of user. 
# ML Formulation :
Building a recommendation system using Collaborative based algorithms like matrix factorization and word embedding. 
# Performance Metric : 
Performance metric for the challenge Area under Receiver Operating Characteristic Curve (AUC ROC) Score. As the both the classed are balanced in dataset so, we will choose AUC ROC not F1-Score. We can also choose Accuracy over AUC ROC as classes are balanced but advantage of AUC ROC score is that we can get correct threshold if we are using linear models like Linear Regression or Logistic Regression.
# Deployed Link
http://ec2-18-188-5-2.us-east-2.compute.amazonaws.com:8080/
