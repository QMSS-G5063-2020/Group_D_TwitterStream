# -*- coding: utf-8 -*-
"""
Created on Mon Oct 23 18:46:31 2017

@author: lemonlinn
"""
import tweepy
import pickle
from textwrap import TextWrapper
from collections import deque
import numpy as np

my_vec_tfidf = pickle.load(open("tfidf.pkl", "rb"))
pca = pickle.load(open("pca.pkl", "rb"))
clf_pca = pickle.load(open("clf_pca.pkl", "rb"))

class MyStreamListener(tweepy.StreamListener):
    
    sent_score = [0] * 100
    
    global d
    d = deque(sent_score)

    def on_status(self, status):
        status_wrapper = TextWrapper(width=140, initial_indent='', subsequent_indent='')
        try:
            my_dict = dict()
            my_dict['body'] = status_wrapper.fill(status.text)
            my_dict['isRetweet'] = status.retweeted
            my_dict['userLanguage'] = status.user.lang
            my_dict['urls'] = status.entities['urls']
            my_dict['place'] = status.place
            my_dict['followerCount'] = status.user.followers_count
            my_dict['screenName'] = status.author.screen_name
            my_dict['friendCount'] = status.user.friends_count
            my_dict['createdAt'] = status.created_at
            my_dict['messageId'] = status.id
            
        except:
            pass
        
        test_text = my_vec_tfidf.transform([my_dict['body']]).toarray()
        test_text_pca = pca.transform(test_text)
        my_dict['classified'] = clf_pca.predict(test_text_pca)[0]
        my_dict['probability'] = max(list(clf_pca.predict_proba(test_text_pca)[0]))
        
        if (my_dict['classified'] == 'neg') and (not(my_dict['isRetweet'])):
            d.popleft()
            d.append(-1*(my_dict['probability']))
            #print(round(np.mean(d), 4))
        elif (my_dict['classified'] == 'pos') and (not(my_dict['isRetweet'])):
            d.popleft()
            d.append(my_dict['probability'])
            #print(round(np.mean(d), 4))
        
        print(my_dict)
