setwd("/media/deepak/OS");
a=read.csv("rankednew.csv");

broad=sqldf("select * from a where clickshare < 0.05  and clicks > 10 and CTR <= 1  order by qcnt desc");
wide=sqldf("select * from a where clickshare > 0.5 and clicks > 50 and CTR <= 1 order by qcnt desc");

library(ggplot2);
qplot(broad$CTR,geom="histogram",xlim=c(0,1));
qplot(wide$CTR,geom="histogram",xlim=c(0,1));
ggplot() + geom_histogram(aes(wide$CTR),color="red",fill=I("red")) + labs(xlim=c(0,1));

ggplot() + geom_histogram(aes(broad$CTR),color="blue",fill=I("blue")) + labs(xlim=c(0,1));
ggplot() + geom_histogram(aes(wide$CTR,binwidth=0.005),color="red",fill=I("red")) + geom_histogram(aes(broad$CTR,binwidth=0.005),color="blue",fill=I("blue")) + geom_density() + labs(xlim=c(0,1)) + stat_function(fun=dnorm, args=list(mean=mean(wide$CTR), sd=sd(wide$CTR)))+
  labs(title="01. Distribuição percentual de demandas por PF",
       y="Percentual") ;
curve(dnorm(broad, mean=mean(CTR), sd=sd(CTR)), add=TRUE, col=”darkblue”, lwd=2)


ggplot() + geom_histogram(aes(wide$CTR,binwidth=0.005),color="red",fill=I("red")) + geom_histogram(aes(broad$CTR,binwidth=0.005),color="blue",fill=I("blue")) + geom_density() + geom_line(aes(y = ..density.., colour = 'Empirical'), stat = 'density') + stat_function(fun=dnorm, color = "black",args=list(mean=mean(broad$CTR), sd=sd(broad$CTR)))  + labs(xlim=c(0,1),x="CTR",y="Query Count")  + scale_colour_manual(name="Line Color",values=c("blue"="Broad", "red"="Specific"))

ggplot() + geom_histogram(aes(wide$CTR,binwidth=0.005),color="red",fill=I("red")) + geom_histogram(aes(broad$CTR,binwidth=0.005),color="blue",fill=I("blue")) + geom_density() + geom_line(aes(y = ..density.., colour = 'Empirical'), stat = 'density') + stat_function(fun=dnorm, color = "black",args=list(mean=mean(broad$CTR), sd=sd(broad$CTR)))  + labs(xlim=c(0,1),x="CTR",y="Query Count")  + scale_colour_manual(name="Line Color",values=c("line"="Broad", "red"="Specific"))


   curve(dnorm(x,mean=mean(broad$CTR),sd=sd(broad$CTR)),col="blue",lwd=2,xlab="CTR",ylab="Count of Queries")
   curve(dnorm(x,mean=mean(wide$CTR),sd=sd(wide$CTR)),col="red",lwd=2,add=TRUE)


 curve(dnorm(x,mean=mean(wide$CTR),sd=sd(wide$CTR)),col="red",lwd=2,add=TRUE)