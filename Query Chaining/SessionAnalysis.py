import pandas as pd
from pandas import Series, DataFrame
import datetime as dt
import string
import numpy as np
import sys

#pre-process
os.chdir("/home/deepak/Downloads")
input=pd.read_csv('keyword_file.csv',sep=",",header=False)        #read file
input.columns=['email','keyword']

#function to compare two strings for replacement
def compareStrings(a,b):
    x=a.split(' ');
    y=b.split(' ');
    z=[i for i in y if i not in x];
    if(len(z) == 1):
        return(z[0]);
    else:
        return(-1);
        
#additions                
def compareStrings(a,b):
    if(a in b):
        if(  b.replace(a,'').startswith(' ') and len(b.replace(a,'').strip().split(' ')) == 1):
            return([a,b.replace(a,'').strip()]);
        else:
            return([-1,-1]);
    else:
        return([-1,-1]);
        
#replacements
def compareStrings(a,b):
    if(len(a.split(' ')) == len(b.split(' '))):
        x=a.split(' ');
        y=b.split(' ');
        z=[[x[i],y[i]] for i in range(0,len(x)) if x[i] != y[i]];
        if( len(z) ==1  ):
            return([z[0][0],z[0][1]]);
        else:
            return([-1,-1]);
    else:
        return([-1,-1]);
        
#removals
def compareStrings(a,b):
        x=a.split(' ');
        y=b.split(' ');
        z=list(set(x) - set(y))
        if( len(z) ==1 and len(y) == len(x) - 1  ):
            return([a,z[0]]);
        else:
            return([-1,-1]);


#iterate over data
sys.stdout = open('removal.csv', 'w')
print 'keyword,addition'
x=input.email[0];y=input.keyword[0];
for index,row in input.iterrows():
    try:    
        if( row['email'] != x ):
            x=row['email']
            y=row['keyword']
        else:
            label=compareStrings(y,row['keyword']);
            if( label[0] != -1 ):
                print label[0],",",label[1];
            y=row['keyword'];
    except:
        pass
            
#aggregate data
input1=pd.read_csv('removal.csv',sep=",",header=True)      ;
input1.columns=['keyword','addition'];
input2=input1.groupby(input1['keyword'].map(str)+'->'+input1['addition']).count().sort(['keyword'],ascending=False)
input2.to_csv("removals_aggregate.csv");    
