import os
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import  TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier
import pandas as pd
import numpy as np
import sys
sys.path.append('/usr/local/lib/python2.7/dist-packages')
import nltk
from nltk.corpus import stopwords
import re
from bs4 import BeautifulSoup   
import cPickle
import sklearn
from sklearn.pipeline import Pipeline
from sklearn.grid_search import GridSearchCV	


os.chdir('/home/deepak/Documents/Projects/QUL Labeling Model/Modeling/Set2');


def review_to_words(raw_review ):
    #p1= re.compile('^[0-9]*[0-9]$');
    #p2= re.compile('sdl*');

    review_text = BeautifulSoup(raw_review).get_text() 
    #
    # 2. Remove non-letters        
    letters_only = re.sub("[^a-zA-Z-]", " ", review_text) 
    #
    # 3. Convert to lower case, split into individual wofurniturerds
    words = letters_only.lower().split()                             
    #
    # 4. In Python, searching a set is much faster than searching
    #   a list, so convert the stop words to a set
    stops = set(stopwords.words("english"))                  
    #stops=[]
    # 
    # 5. Remove stop words
    #meaningful_words = [w for w in words if not w in stops and not p2.match(w) and not p1.match(w)]   
    meaningful_words = [w for w in words if not w in stops ]   
    #
    # 6. Join the words back into one string separated by space, 
    # and return the result.
    return( " ".join( meaningful_words ))   
    
vectorizer = CountVectorizer(analyzer = "word",   \
                             tokenizer = None,    \
                             #ngram_range=(1),  \
                             preprocessor = None, \
                             stop_words = None,   \
                             #use_idf=True, \
                             max_features = 5000,
                             vocabulary=vocab)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ;
                                                     
    
#import model
forest=cPickle.load( open("model_rf_cat","rb" ));
tokenizer=cPickle.load( open("tokenzier_v","rb" ));
vocab=cPickle.load(open("vocab","rb"));

#run on test set
input="furniture for home"
x=[];
x.append(review_to_words(input));
test_data_features = vectorizer.transform(x)
test_data_features = test_data_features.toarray()      
result = forest.predict(test_data_features)
print result
#print sklearn.metrics.accuracy_score(test["category"],result)

    
            