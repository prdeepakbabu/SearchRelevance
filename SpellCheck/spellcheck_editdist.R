setwd("/home/deepak/Documents/Projects/SpellChecking/run2");
library(stringdist);
library(sqldf);

file="output_app.txt"
fl_tgt=paste("classified_",file,sep="");
fl_ins=paste("ins_",file,sep="");
fl_del=paste("del_",file,sep="");
fl_rep=paste("rep_",file,sep="");
fl_trans=paste("trans_",file,sep="");

#keyboard proximity tables
before<-new.env();
after<-new.env();
before[["a"]]<-"9";
before[["b"]]<-"v";
before[["c"]]<-"x";
before[["d"]]<-"s";
before[["e"]]<-"w";
before[["f"]]<-"d";
before[["g"]]<-"f";
before[["h"]]<-"g";
before[["i"]]<-"u";
before[["j"]]<-"h";
before[["k"]]<-"j";
before[["l"]]<-"k";
before[["m"]]<-"n";
before[["n"]]<-"b";
before[["o"]]<-"i";
before[["p"]]<-"o";
before[["q"]]<-"9";
before[["r"]]<-"e";
before[["s"]]<-"a";
before[["t"]]<-"r";
before[["u"]]<-"y";
before[["v"]]<-"c";
before[["w"]]<-"q";
before[["x"]]<-"z";
before[["y"]]<-"t";
before[["z"]]<-"9";
after[["a"]]<-"s";
after[["b"]]<-"n";
after[["c"]]<-"v";
after[["d"]]<-"f";
after[["e"]]<-"r";
after[["f"]]<-"g";
after[["g"]]<-"h";
after[["h"]]<-"j";
after[["i"]]<-"o";
after[["j"]]<-"k";
after[["k"]]<-"l";
after[["l"]]<-"9";
after[["m"]]<-"9";
after[["n"]]<-"m";
after[["o"]]<-"p";
after[["p"]]<-"9";
after[["q"]]<-"w";
after[["r"]]<-"t";
after[["s"]]<-"d";
after[["t"]]<-"y";
after[["u"]]<-"i";
after[["v"]]<-"b";
after[["w"]]<-"e";
after[["x"]]<-"c";
after[["y"]]<-"u";
after[["z"]]<-"x";


#read input file
fl=read.csv(file,sep="|",col.names=c('original','spellcor'));
len=nrow(fl);
trim <- function (x) gsub("^\\s+|\\s+$", "", x);
getdist <- function(x,y)
{
  dis=stringdist(x,y,method="dl");
  return(dis);
}

getflag <- function(x,y)
{
  lx=nchar(x);
  ly=nchar(y);
  if( ly > lx)
  {
    #print(paste(lx,ly));
    if(grepl(x,y) == 1) #grep(x,y)
    {
      return("INSERT-END");
    }
    else if(grepl(" ",y))
    {
      return("INSERT-SPACE");
    }
    else
    {
      return("INSERT");      
    }
  }
  else if( ly < lx)
  {
    return("DELETE");
  }
  else
  {
    #check for replace or transposition
    x1=strsplit(x,"");
    y1=strsplit(y,"");
    cnt = 0;
    left="a";right="a";
    for(z in 1:lx)
    {
      if(x1[[1]][[z]] != y1[[1]][[z]])
      {
        cnt=cnt+1;
        left =x1[[1]][[z]];
        right= y1[[1]][[z]];
      }
    }
    if(cnt == 1)
    { res=tryCatch({     
      if(after[[left]]==right)
      {
        return("REPLACE-AFTER");
      }
      else if(before[[left]]==right)
      {
        return("REPLACE-BEFORE");
      }
      else
      {
        return("REPLACE");
      }
    },error = function(err){return("REPLACE");})
    }
    else
    {
      return("TRANSPOSE");
    }
  }
}

#actual tagging
for(i in 1:len)
{
  original=tolower(fl[i,1]);
  if( fl[i,2] != ",,")
    {spellc=strsplit(as.character(fl[i,2]),",");}
  else
    {next;}
  #for( j in 1:length(spellc[[1]]))
  for( j in 1:1)
  {
    suggest=tolower(spellc[[1]][[j]]);
    editdist=getdist(original,suggest);
    if( editdist == 1)
    {
      class=getflag(original,suggest);
      abc=paste(as.character(original),as.character(suggest),class,sep=",");
      cat(abc,file=fl_tgt,sep="\n",append=TRUE);
      #print(paste(as.character(original),suggest,as.character(editdist),sep=","));
    }
    #print(paste(as.character(original),suggest,as.character(editdist),sep=","));
  }
}

#for( i in 1:length(a1[[1]])) { 
#  if( a1[[1]][[i]] != a2[[1]][[i]])
#  {
#    print(i);
#  }
#}

d=read.csv(fl_tgt,sep=",");
colnames(d)=c('original','suggest','class');
dd=sqldf("select class,count(*) from d group by 1");
write.csv(dd,paste("summary_",fl_tgt,sep=""));

