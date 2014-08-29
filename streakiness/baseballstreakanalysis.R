yearlist<-c(1975:1980, 1982:1988, 1990:2001, 2003:2013) #I don't want to debug these years right now

fullteamschedule<-data.frame(X.2=as.integer(character()),
                             Rk=as.integer(character()),
                             Gm.=as.factor(character()),
                             Date=as.factor(character()),
                             X=as.factor(character()),
                             Tm=as.factor(character()),
                             X.1=as.factor(character()),
                             Opp=as.factor(character()),
                             W.L=as.factor(character()),
                             R=as.integer(character()),
                             RA=as.integer(character()),
                             Inn=as.integer(character()),
                             W.L.1=as.factor(character()),
                             Rank=as.integer(character()),
                             GB=as.factor(character()),
                             Win=as.factor(character()),
                             Loss=as.factor(character()),
                             Save=as.factor(character()),
                             Time=as.factor(character()),
                             D.N=as.factor(character()),
                             Attendance=as.integer(character()),
                             Streak=as.factor(character()),
                             WinorLoss=as.factor(character()),
                             Year=as.integer(character())
                             )

for(i in 1:length(yearlist)){
    year <- yearlist[i]
    yearstr <- as.character(year)
    #CSV files from here - http://www.baseball-reference.com/teams/ATL/2009-schedule-scores.shtml
    filestr<- paste("teams_ATL_", yearstr,"-schedule-scores_team_schedule.csv", sep="")

    teamschedule<-read.csv(filestr)

    teamschedule<-teamschedule[teamschedule$Streak!="Streak",]
    write.csv(teamschedule, "teamschedule.csv")
    teamschedule<-read.csv("teamschedule.csv")
    teamschedule$WinorLoss <- as.factor(substr(teamschedule$W.L,1,1))
    teamschedule$WinorLoss <- factor(teamschedule$WinorLoss, levels(teamschedule$WinorLoss)[c(2,1)])
    teamschedule$Year <- year
    
    #remove ties (there's one in 2002)
    teamschedule<-teamschedule[teamschedule$WinorLoss!="T",]

    fullteamschedule<-rbind(fullteamschedule, teamschedule)
}

## First - define new streak if Loss changes to Win or vice versa
fullteamschedule<-fullteamschedule[!is.na(fullteamschedule$WinorLoss),]
#for now, let's get rid of 2002 (giving me trouble)
#fullteamschedule<-fullteamschedule[fullteamschedule$Year!=2002,]
fullteamschedule$StreakNo[1]<-1
fullteamschedule$Count <- 1
for(i in 2:length(fullteamschedule$WinorLoss)){
    if(fullteamschedule$WinorLoss[i]==fullteamschedule$WinorLoss[i-1]){
        fullteamschedule$StreakNo[i]<-fullteamschedule$StreakNo[i-1]
    }
    else {
        fullteamschedule$StreakNo[i]<-fullteamschedule$StreakNo[i-1]+1
    }
    if(fullteamschedule$Year[i]!=fullteamschedule$Year[i-1]){
        fullteamschedule$StreakNo[i]<-1
    }
    
}

library(plyr)
summarybystreak <- ddply(fullteamschedule, .(StreakNo, WinorLoss, Year), summarize, NGames=sum(Count))
quantilesbyyear <- ddply(summarybystreak, .(Year), summarize, Quantiles=list(quantile(NGames, probs=c(0,0.05, 0.25, 0.5, 0.75, 0.95,1))))
a<-t(as.data.frame(quantilesbyyear[,2]))
row.names(a)<-quantilesbyyear$Year
quantilesbyyear<-as.data.frame(a)
quantilesbyyear$Year<-row.names(quantilesbyyear)
histogram(quantilesbyyear$"95%")
barplot(quantilesbyyear$"95%", names.arg=quantilesbyyear$Year)


histogram( ~ summarybystreak$NGames | summarybystreak$Year*summarybystreak$WinorLoss, nint=max(summarybystreak$NGames, na.rm=TRUE))
Wquantiles<-quantile(summarybystreak$NGames[summarybystreak$WinorLoss=="W"])
Lquantiles<-quantile(summarybystreak$NGames[summarybystreak$WinorLoss=="L"])
xyplot(NGames ~ StreakNo, data=summarybystreak, groups=WinorLoss)
StreakLength<-4
NumLongStreaksWL<-ddply(summarybystreak, .(Year, WinorLoss), summarize, LongStreaks = sum(NGames>StreakLength), LongStreakPerc = sum(NGames[NGames>StreakLength])/162)
NumLongStreaks<-ddply(summarybystreak, .(Year), summarize, LongStreaks = sum(NGames>StreakLength), LongStreakPerc = sum(NGames[NGames>StreakLength])/162)
xyplot(LongStreaks~Year, data = NumLongStreaks)