# -*- coding: utf-8 -*-
"""
Created on Sat Nov 16 18:40:51 2019

@author: lemonlinn
"""
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.model_selection import GridSearchCV
from nltk.corpus import stopwords
import re, os
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier
import pickle

class MLClass(object):
    
    def __init__(self):
        print("Let's get this started!")
        
    def clean_up_sw(self, var):
        stop_words = set(stopwords.words('english'))
    
        tmp = re.sub('[^a-zA-Z]+', ' ', var)
        tmp = [word for word in tmp.split() if word not in stop_words]
        tmp = ' '.join(tmp)

        return(tmp)
    
    def fetch_df(self, the_path_in):
        the_dirs = os.listdir(the_path_in)
        the_df_out = pd.DataFrame()
        for dir_name in the_dirs:
            the_filenames = os.listdir(the_path_in + "/" + dir_name)
            for word in the_filenames:
                f = open(the_path_in + "/" + dir_name + '/' + word, "r", encoding='ISO-8859-1')
                tmp_read = str(f.read())
                tmp = pd.DataFrame([self.clean_up_sw(tmp_read)], columns=['body'])
                tmp['label'] = dir_name
                the_df_out = the_df_out.append(tmp, ignore_index=True)
                f.close()
            
        return(the_df_out)
    
    def iterate_var(self, my_xform_tfidf_in, var_target, data_slice):
        """PCA using smallest possible # of components to hit target EVR"""
        print("Dimension reduction in progress! One moment, please!")
        var_fig = 0.0
        cnt = 1
        while var_fig <= var_target:
            pca = PCA(n_components=cnt)
            my_dim = pca.fit_transform(my_xform_tfidf_in[0:data_slice])
            var_fig = sum(pca.explained_variance_ratio_)   
            cnt += 1
        pca = PCA(n_components=cnt)
        my_dim = pca.fit_transform(my_xform_tfidf_in)

        return(my_dim, pca)
    
    def grid_search_func(self, param_grid, the_mode_in, the_vec_in, the_lab_in):
        """Gives best possible combination of hyperparameters based on grid options"""
        print("Grid search in progress! One moment, please!")
        grid_search = GridSearchCV(the_mode_in, param_grid=param_grid, cv=5)
        best_model = grid_search.fit(the_vec_in, the_lab_in)
        max_score = grid_search.best_score_
        best_params = grid_search.best_params_

        return(best_model, max_score, best_params)
        
    def MLTrainer(self):
        the_path = os.path.abspath('./Documents/GitHub/NLP2019/Lemon_HW4/theData/train/')
        the_df = self.fetch_df(the_path)
        my_vec_tfidf = TfidfVectorizer()
        my_xform_tfidf = my_vec_tfidf.fit_transform(the_df.body).toarray()
        col_names = my_vec_tfidf.get_feature_names()
        my_xform_tfidf = pd.DataFrame(my_xform_tfidf, columns=col_names)
        my_dim, pca = self.iterate_var(my_xform_tfidf, 0.95, 200)
        param_grid = {"max_depth": [10, 50, 100],
                         "n_estimators": [16, 32, 64],
                         "random_state": [1234]}
        clf_pca = RandomForestClassifier()
        gridsearch_model, best, opt_params = self.grid_search_func(
                param_grid, clf_pca, my_xform_tfidf, the_df.label)
        clf_pca = RandomForestClassifier()
        clf_pca.set_params(**gridsearch_model.best_params_)
        clf_pca.fit(my_dim, the_df.label)
        pickle.dump(clf_pca, open("clf_pca.pkl", "wb"))
        pickle.dump(pca, open("pca.pkl", "wb"))
        pickle.dump(my_vec_tfidf, open("tfidf.pkl", "wb"))
        return(my_vec_tfidf, pca, clf_pca)
    
    