# -*- coding: utf-8 -*-
"""
Created on Wed Nov 20 13:27:05 2019

@author: lemonlinn
"""

#%% Notes
#
# Change out the ckey, csecret, atoken, and asecret to your own twitter API.
#
# You can also change out the_regex.
#
#%% import step
from Documents.GitHub.NLP2019.Lemon_Streamer_Tweepy.Lemon_ML import MLClass
from Documents.GitHub.NLP2019.Lemon_Streamer_Tweepy.Lemon_API import MyStreamListener
import tweepy

#%% train model

MyML = MLClass()
my_vec_tfidf, pca, clf_pca = MyML.MLTrainer()

#%% call MyStreamListener

ckey=""
csecret=""
atoken=""
asecret=""

auth = tweepy.auth.OAuthHandler(ckey, csecret)
auth.set_access_token(atoken, asecret)

api = tweepy.API(auth)

the_regex = '#DemDebates'

myStreamListener = MyStreamListener()
myStream = tweepy.Stream(auth = api.auth, listener=myStreamListener)

myStream.filter(track=[the_regex])

