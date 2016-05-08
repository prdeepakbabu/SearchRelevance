import sys
sys.path.append('/usr/local/lib/python2.7/dist-packages')
import pandas as pd
import os
import re
os.chdir("/home/deepak/Documents/Projects/HMM/WordDrop")

inp = pd.read_csv("queries2.csv")
inp.columns=['query','count']
count = sum(inp['count'])

query = "liberty women safety shoes"

def startProb(x):
    return sum(inp[inp['query'].str.contains('^'+x)==True]['count'])/ count
    
def CondProb(x,y):
    return sum(inp[inp['query'].str.contains(x+' '+y)==True]['count'])/ sum(inp[inp['query'].str.contains(y)==True]['count'])
    
def calcProb(x):
    words=x.split(' ');
    qlen=len(words);
    a=range(0,qlen)
    a.sort(reverse=True);
    res = 1;
    for i in a:
        if i == 0:
            res = res * startProb(words[i])
            return float(res);
        res = res * CondProb(words[i-1],words[i]);
    
        
        
def getWordDrop(query):
    words = query.split(' ');
    qlen=len(words);
    a=range(0,qlen);
    res_prob= [None] * qlen
    for j in range(0,qlen):
        b=[j]
        tmp=sort(list(set(a) - set(b)))
        tmp1=[words[i] for i in tmp]
        iter = ' '.join(tmp1)
        res_prob[j]=calcProb(iter);
    return words[res_prob.index(max(res_prob))], res_prob
    
    
eval = pd.read_csv("evaluation.txt");
eval.columns = ['query']
eval['remove']=[getWordDrop(a) for a in eval['query']]
eval.to_csv("eval_drops.txt")

    
