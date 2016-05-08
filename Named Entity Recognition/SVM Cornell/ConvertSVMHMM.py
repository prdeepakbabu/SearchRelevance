sys.path.append('/usr/local/lib/python2.7/dist-packages')
import re
import nltk
from nltk import word_tokenize
from nltk import sent_tokenize
import nltk.stem
from nltk.stem import WordNetLemmatizer
lemma=WordNetLemmatizer();
#nltk.download();
from nltk.stem.porter import *
from nltk.stem.snowball import SnowballStemmer
stemmer = PorterStemmer()
stemmer = SnowballStemmer("english")
lemma.lemmatize("mobiles")
import pandas as pd
import numpy
import os
from sklearn.cross_validation import train_test_split
'''
Class Code
=============
0 none
5 quantity
4 metric
2 brand
3 color
1 category
6 year
7 audience
8 currency
9 price
10 Author
11 Occasion (wedding/birthday/anniversary)
'''
os.chdir("/home/deepak/Documents/Projects/QUL Labeling Model/NER")
brands=pd.read_csv("brands",header=False);
brands.columns=['brand']
brands1=[w.lower() for w in brands['brand'] if len(str(w).split(' ')) == 1]
brands=set(list(brands1))
audience=['men','women','kid','children','boy','girl','lady','man','baby']
year=['2016','2015','2014']
occasion=['wedding','marriage','anniversary','birthday'];
colors=pd.read_csv("colors1",header=False);
colors.columns=['col']
col=[str(w).lower() for w in colors['col']]
colors=list(set(col));
cats=pd.read_csv("label",header=False);
cats.columns=['col']
col=[str(w).lower() for w in cats['col']]
cat=list(set(col));
metrics=pd.read_csv("metric",header=False);
metrics.columns=['col']
col=[str(w).lower() for w in metrics['col']]
metrics=list(set(col));
currency=['rs','rupees','rupee','inr','rs.'];


inp=pd.read_csv("queries.txt")
inp.columns=['query']
inp['word_cnt']=[len(str(w).split(' ')) for w in inp['query'] ]
inp1 = inp[inp['word_cnt'] > 2]

def getClass(x):
    tokens=word_tokenize(x);
    tokens_cleaned=[lemma.lemmatize(x).lower() for x in tokens];
    tokens_features=[0 for x in tokens_cleaned]
    token_brand=[2 if x in brands else 0 for x in tokens_cleaned];
    token_category=[1 if x in cat else 0 for x in tokens_cleaned];    
    token_year=[6 if x in year else 0 for x in tokens_cleaned];
    token_audience=[ 7 if x in audience else 0 for x in tokens_cleaned];
    token_color=[ 3 if x in colors else 0 for x in tokens_cleaned];
    token_metrics=[4 if x in metrics else 0 for x in tokens_cleaned];
    token_currency=[8 if x in currency else 0 for x in tokens_cleaned]; 
    token_occasion=[11 if x in occasion else 0 for x in tokens_cleaned]; 
    tok=numpy.maximum(numpy.maximum(numpy.maximum(numpy.maximum(numpy.maximum(numpy.maximum(numpy.maximum(numpy.maximum(tokens_features,token_brand),token_year),token_audience),token_color),token_category),token_metrics),token_currency),token_occasion);
    return(' '.join(tok.astype(str)));
    
inp1['features']=[getClass(x) for x in inp1['query']]    
inp1['feature_cnt_0']=[x.count('0') for x in inp1['features']]
inp1['percent_label']=(inp1['word_cnt'] - inp1['feature_cnt_0'])*1.00/inp1['word_cnt']

inp1[inp1['features'].str.contains('6')]
inp2=inp1[inp1['percent_label'] > 0.7 ]
inp2[inp2['features'].str.contains('6')]
inp2['cleanquery']=[str(re.sub('[^0-9a-zA-Z ]+','',x).replace("'","")) for x in inp2['query']]
list(set(word_tokenize((list(inp2['cleanquery'])))))
vocab=list(set( word_tokenize(' '.join(inp2['query']))))
vocab=[lemma.lemmatize(x) for x in vocab]
vocab=list(set(vocab));

def getFeatures(x,i):
    tokens=word_tokenize(x);
    tokens_cleaned=[lemma.lemmatize(x).lower() for x in tokens];
    tokens_features=[0 for x in tokens_cleaned]
    token_brand=[2 if x in brands else 0 for x in tokens_cleaned];
    token_category=[1 if x in cat else 0 for x in tokens_cleaned];    
    token_year=[6 if x in year else 0 for x in tokens_cleaned];
    token_audience=[ 7 if x in audience else 0 for x in tokens_cleaned];
    token_color=[ 3 if x in colors else 0 for x in tokens_cleaned];
    token_metrics=[4 if x in metrics else 0 for x in tokens_cleaned];
    token_currency=[8 if x in currency else 0 for x in tokens_cleaned]; 
    token_occasion=[11 if x in occasion else 0 for x in tokens_cleaned]; 
    #tok=max(token_brand,token_category,token_year,token_audience,token_color,token_metrics,token_currency,token_occasion);
    tok=numpy.maximum(numpy.maximum(numpy.maximum(numpy.maximum(numpy.maximum(numpy.maximum(numpy.maximum(numpy.maximum(tokens_features,token_brand),token_year),token_audience),token_color),token_category),token_metrics),token_currency),token_occasion);
    tok=[str(w).replace("0","99") for w in tok ]
    res=[None]*len(tok)
    for j in range(0,len(tok)):
        res[j]=str(tok[j])+" "+"qid:"+str(i);
        global prev,next;
        prev=0
        next=0
        if j==0:
            prev = 0
            nxt = 1
        elif j==len(tok)-1:
            next = 0
            prev=1
        else:
            prev=1
            next=1
        if bool(re.search('^[0-9]*$',tokens_cleaned[j])):
            res[j]=res[j]+" 1:1"
        if bool(re.search('^[0-9]*$',tokens_cleaned[j-1])) & prev == 1:
            res[j]=res[j]+" 2:1"
        if  next == 1:
           if bool(re.search('^[0-9]*$',tokens_cleaned[j+1])):
               res[j]=res[j]+" 3:1"
        if bool(re.search('^[0-9]*.[0-9]*$',tokens_cleaned[j])):
            res[j]=res[j]+" 4:1"
        if bool(re.search('^[0-9]*.[0-9]*$',tokens_cleaned[j-1])) & prev == 1:
            res[j]=res[j]+" 5:1"
        if next == 1:
            if bool(re.search('^[0-9]*.[0-9]*$',tokens_cleaned[j+1])):
                res[j]=res[j]+" 6:1"            
        if bool(re.search('^[0-9].*[a-z]$',tokens_cleaned[j])):
            res[j]=res[j]+" 7:1"
        if bool(re.search('^[0-9].*[a-z]$',tokens_cleaned[j-1])) & prev == 1:
            res[j]=res[j]+" 8:1"
        if  next == 1:
            if bool(re.search('^[0-9].*[a-z]$',tokens_cleaned[j+1])):
                res[j]=res[j]+" 9:1"
        if bool(re.search('^[a-z].*[0-9]$',tokens_cleaned[j])):
            res[j]=res[j]+" 10:1"
        if bool(re.search('^[a-z].*[0-9]$',tokens_cleaned[j-1])) & prev == 1:
            res[j]=res[j]+" 11:1"
        if  next == 1:
            if bool(re.search('^[a-z].*[0-9]$',tokens_cleaned[j+1])):
                res[j]=res[j]+" 12:1"            
        if prev == 1 & next == 0:
           #if bool(re.search('^[0-9]*$',tokens_cleaned[j-1])):
           #    res[j]=res[j]+" 5:1"
           # if bool(re.search('^[0-9]*.[0-9]*$',tokens_cleaned[j-1])):
           #    res[j]=res[j]+" 6:1" 
           # if bool(re.search('^[0-9].*[a-z]$',tokens_cleaned[j-1])):
           #    res[j]=res[j]+" 7:1" 
           # if bool(re.search('^[a-z].*[0-9]$',tokens_cleaned[j-1])):
           #    res[j]=res[j]+" 8:1" 
           res[j]=res[j]+" "+str(13+vocab.index(tokens_cleaned[j-1]))+":1"
        if next == 1 & prev == 0:
            res[j]=res[j]+" "+str(13+len(vocab)+vocab.index(tokens_cleaned[j+1]))+":1"
        if next ==1 & prev == 1:
            prev_token=vocab.index(tokens_cleaned[j-1])     
            next_token=vocab.index(tokens_cleaned[j+1])     
            res[j]=res[j]+" "+str(13+vocab.index(tokens_cleaned[j-1]))+":1 "+str(13+len(vocab)+vocab.index(tokens_cleaned[j+1]))+":1"
            #if prev_token > next_token:
            #    res[j]=res[j]+" "+str(13+len(vocab)+vocab.index(tokens_cleaned[j+1]))+":1 "+str(13+vocab.index(tokens_cleaned[j-1]))+":1"
            #else:
            #    res[j]=res[j]+" "+str(13+vocab.index(tokens_cleaned[j-1]))+":1 "+str(13+len(vocab)+vocab.index(tokens_cleaned[j+1]))+":1"
        res[j] = res[j]+" #"+tokens_cleaned[j]     
    return(res);  


#run on all queries
train, test = train_test_split(inp2['query'], test_size = 0.2);
train=train.to_frame().reset_index();
train.columns=['idx','query']
test=test.to_frame().reset_index();
test.columns=['idx','query']
global train_res
global test_res
train_res = [None] * len(train)
test_res = [None] * len(test)
train_res=getFeatures(train['query'][0],0);
for i in range(1,len(train)):
    tmp= getFeatures(train['query'][i],i)
    train_res.extend(tmp)
    
test_res=getFeatures(test['query'][0],0);
for i in range(1,len(test)):
    tmp= getFeatures(test['query'][i],i)
    test_res.extend(tmp)
    
fl=open("training.txt","w+");
for item in train_res:
  fl.write("%s\n" % item)    
fl.close()

fl=open("testing.txt","w+");
for item in test_res:
  fl.write("%s\n" % item)    
fl.close()

