import os
import pandas as pd
import datetime as dts
import sys

###########################################
# Using recursion to create json for viz
###########################################
#read the input file with just all search terms
z4=pd.read_csv("/home/deepak/input.csv",sep=",",header=0,dtype=str); 

#write output to a file to create intermediate structure
#from,to,level
#bluetooth,speakers,0
#speakers,sony,1
#.....
sys.stdout = open('/home/deepak/keywords.csv', 'w');
lent=len(z4);
for index,row in z4.iterrows():
    tokens=row['keyword'].replace('  ',' ').strip().split(' ');
    i=0;
    while (i <= len(tokens)-2):
        print tokens[i],",",tokens[i+1],",",i
        i=i+1;
        
inp=pd.read_csv("/home/deepak/keywords.csv",sep=",",header=0,dtype=str);  
inp1=inp.drop_duplicates();
inp1.columns=['from','to','level'];    

#using the intermediate step (inp1) recursive function defined to concatenate the children strings to form complete JSON
last=2;
#getchild("bluetooth","0")
def getchild(query,level):
    tmp=inp1[(inp1['from'].str.replace(' ','') == query) & (inp1['level'].str.replace(' ','') == level)];
    glb1="{\"name\":\"" + query + "\","  +  "\"children\":["   ;
    glb2="]}";
    lcl=""
    for x in tmp.to:
        lcl = lcl + getchild(x.replace(' ',''),str(int(level)+1))   + "," 
    if len(tmp) == 0:
        lcl=""
    if level == last :
        lcl="{\"name\":\"" + query + "}";
    t= glb1+lcl[:-1]+glb2;
    return t;

#call the recursive function
z=getchild("bluetooth","0");    
#use z - remove special char if any in searches + remove start and end quotes before feeding to D3.js
