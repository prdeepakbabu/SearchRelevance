# -*- coding: utf-8 -*-
"""
Created on Tue May  3 16:26:16 2016

@author: deepak
"""
from scipy import spatial
import gensim
from gensim import models
from gensim.models import Word2Vec
import pandas as pd
import os

#import training data
def review_to_words(raw_review ):
    review_text = BeautifulSoup(raw_review).get_text()
    tmp = re.sub(","," ",review_text);
    words = tmp.lower().split()                             
    stops = set(stopwords.words("english"))                  
    meaningful_words = [str(lmtzr.lemmatize(w)) for w in words if not w in stops ]        
    res = [None] * len(meaningful_words); counter = 0;
    for i in meaningful_words:
        if re.match("[a-z]+[0-9]+",i) :
            tmp = re.sub("[0-9]+","[d]",i)
            tmp1 = re.sub("[a-z]+","[c]",tmp)
            res[counter] = tmp1
        else:
            res[counter]= i
        counter = counter + 1
    #return( " ".join( res ))   
    return(" ".join(res))   

os.chdir("/home/deepak/Documents/Projects/TopicModeling")
train = pd.read_csv("bintrigrams.txt", header=0,delimiter=",",encoding ='UTF-8');
train.columns=['query']
num_rows = train["query"].size
clean_query = []

for i in xrange( 0, num_rows ):
    try:
        clean_query.append( review_to_words( train["query"][i] ) )
    except:
        pass

a= []
for i in range(0,len(train)):
    try:
        #a.append(str(train['query'][i]).split())
        a.append(str(clean_query[i]).split())
    except:
        continue
    
#model = Word2Vec(a, size=300, window=3, min_count=10, sg=1 ,iter = 20,workers=4,sample = 1e-3)    
model = Word2Vec(a, size=10, window=3, min_count=10, sg=1 ,iter = 5,workers=4,sample = 1e-3)
vocab = list(model.vocab.keys())
print model.most_similar(positive=['micromax'])
first=getAvgFeatureVecs(['micromax canvas'],model,300)
second=getAvgFeatureVecs(['samsung galaxy'],model,300)
result = spatial.distance.cosine(first,second)
print result

distance.euclidean(first,second)

model.init_sims(replace=True)
model.save("nextmodel")

cosine_similarity = numpy.dot(first,second)/(numpy.linalg.norm(first)* numpy.linalg.norm(second))

#final['query']=[" ".join(a[i]) for i in range(len(a))]
final=train;
tmp = getAvgFeatureVecs(a,model,300)
final1=pd.concat([final,pd.DataFrame(tmp)],axis=1)
nm=["feature_"+str(i) for i in range(303)]
final1.columns= nm;
final2 = final1[  pd.isnull(final1.feature_3) == False]
final2.to_csv("query_wordvecs.csv",encoding='utf-8')

def getAvgFeatureVecs(reviews, model, num_features):
    # Given a set of reviews (each one a list of words), calculate 
    # the average feature vector for each one and return a 2D numpy array 
    # 
    # Initialize a counter
    counter = 0.
    # 
    # Preallocate a 2D numpy array, for speed
    reviewFeatureVecs = np.zeros((len(reviews),num_features),dtype="float32")
    # 
    # Loop through the reviews
    for review in reviews:
       #
       # Print a status message every 1000th review
       if counter%1000. == 0.:
           print "Review %d of %d" % (counter, len(reviews))
       # 
       # Call the function (defined above) that makes average feature vectors
       reviewFeatureVecs[counter] = makeFeatureVec(review, model, \
           num_features)
       #
       # Increment the counter
       counter = counter + 1.
    return reviewFeatureVecs
    
def makeFeatureVec(words, model, num_features):
    # Function to average all of the word vectors in a given
    # paragraph
    #
    # Pre-initialize an empty numpy array (for speed)
    featureVec = np.zeros((num_features,),dtype="float32")
    #
    nwords = 0.
    # 
    # Index2word is a list that contains the names of the words in 
    # the model's vocabulary. Convert it to a set, for speed 
    index2word_set = set(model.index2word)
    #
    # Loop over each word in the review and, if it is in the model's
    # vocaublary, add its feature vector to the total
    for word in words:
        if word in index2word_set: 
            nwords = nwords + 1.
            featureVec = np.add(featureVec,model[word])
    # 
    # Divide the result by the number of words to get the average
    featureVec = np.divide(featureVec,nwords)
    return featureVec    