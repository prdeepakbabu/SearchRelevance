import os
import pandas as pd
import datetime as dts
import sys
    
#config params
#session defn. in seconds
session_len_defn=1800;
    
dt=pd.read_csv("/home/deepak/Downloads/log_web.csv/output.csv",sep=",",engine="python");
dt.columns=['uid','email','keyword','ts'];
# for web use %Y-%m-%dT%H:%M:%S   (T) in datetime conversion, not in app
dt['ts']=[t.partition('.')[0] for t in dt['ts']];
dt['ts']=[dts.datetime.strptime(t.replace('Z',''),'%Y-%m-%dT%H:%M:%S') for t in dt['ts']];
dtsort=dt.sort(['uid','ts'],ascending=True);
    
sys.stdout = open('session.csv', 'w')
suid=dtsort.uid[0]; sts=dtsort.ts[0]; skeyword=dtsort.keyword[0]; scnt=1;
for index,row in dt.iterrows():
    delta=row['ts']-sts;
    dlt=delta.seconds;
    if row['uid'] == suid and dlt > session_len_defn:
        scnt=scnt+1;
        dlt=0;
    elif row['uid'] != suid:
        scnt=1; dlt=0;
    else:
        aa=1;
    suid=row['uid'];
    sts=row['ts'];
    print row['uid'],row['ts'],dlt,scnt;
        
sys.stdout = open('stats.csv', 'w')    
inp=pd.read_csv("session.csv",sep=" ",header=0);    
inp.columns=['uid','date','time','delta','session'];        
inp.head(100);        
#go to line  sed -n 1922596p session.csv , delete a line: sed -i '1922596d' session.csv
print "mean",x1.session.mean();
print "median",x1.session.mean();
                                                                                                                                                                                                                                                                                        
#session count distribution
x1=inp['session'].groupby(inp['uid']).max().reset_index();
x2=x1['uid'].groupby(x1['session']).count().reset_index();
x2.to_csv('session_cnt_dist.csv',index=False,header=False) ;
    
#session length distribution
x3=inp.groupby(['uid','session']).sum().reset_index();
x4=x3[x3['session'] < 2];
x5=x4['uid'].groupby(x4['delta']).count().reset_index();
x5.to_csv('first_session_len_dist.csv',index=False,header=True) ;
# mean = x4[x4['delta'] != 0].delta.mean()
# medina = x4[x4['delta'] != 0].delta.median()
print "mean",x4[x4['delta'] != 0].delta.mean()
print "median",x4[x4['delta'] != 0].delta.median()        


#############################################
#get query formulation for head queries     #
#############################################
dtsortsmall=dtsort;
dtsortsmall['keyword']=[t.lower() for t in dtsort['keyword']];
z1=dtsortsmall[dtsortsmall['keyword'].str.contains("^watches *")].reset_index();
z2=z1.groupby(z1['uid']).count().reset_index();
z3=z2[z2['keyword']>1].reset_index();
#z3=z2['uid'].where(z2['keyword']>1).unique().tolist();
z4=z1[z1['uid'].isin(z3.uid)]

lent=len(z4);
i=0;
Matrix = [["NA" for x in range(5)] for x in range(lent)] 
for index,row in z4.iterrows():
    tokens=row['keyword'].split(' ');
    j=0;
    for ij in tokens:
        if j <= 4:
            Matrix[i][j]=ij;
            j=j+1;
    i=i+1;
    
z5=pd.DataFrame(Matrix,columns=['first','second','thrid','fourth','fifth'])
    
        
    
    
    
    
    


