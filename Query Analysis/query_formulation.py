import os
import pandas as pd
import datetime as dts
import sys
    
#config params
#session defn. in seconds
session_len_defn=1800;
    
dt=pd.read_csv("/home/deepak/Downloads/log_web.csv/outputcomplete.csv",sep=",",engine="python");
dt.columns=['uid','email','keyword','ts'];
# for web use %Y-%m-%dT%H:%M:%S   (T) in datetime conversion, not in app
dt['ts']=[t.partition('.')[0] for t in dt['ts']];
dt['ts']=[dts.datetime.strptime(t.replace('Z',''),'%Y-%m-%d %H:%M:%S') for t in dt['ts']];
dtsort=dt.sort(['uid','ts'],ascending=True);

#############################################
#get query formulation for head queries     #
#############################################
dtsortsmall=dtsort;
dtsortsmall['keyword']=[str(t).lower() for t in dtsort['keyword']];
z1=dtsortsmall[dtsortsmall['keyword'].str.contains("^bluetooth *")].reset_index();
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
    
z5=pd.DataFrame(Matrix,columns=['first','second','thrid','fourth','fifth']);

#set the keyword
z6= z5.where(z5['first']=='bluetooth');
z7=z6.groupby(['first','second','thrid']).count().sort(['fourth'],ascending=False).reset_index()
z7.to_csv('/home/deepak/Documents/Projects/TrendingSearches/iphone_query_formulation.csv',index=False,header=True) ;

