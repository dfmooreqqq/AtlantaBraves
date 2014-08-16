yearlist<-c(2010:2013)
year<-2009
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

fullteamschedule<-rbind(fullteamschedule, teamschedule)

}

## First - define new streak if Loss changes to Win or vice versa
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
histogram( ~ summarybystreak$NGames | summarybystreak$Year*summarybystreak$WinorLoss, nint=max(summarybystreak$NGames, na.rm=TRUE))
Wquantiles<-quantile(summarybystreak$NGames[summarybystreak$WinorLoss=="W"])
Lquantiles<-quantile(summarybystreak$NGames[summarybystreak$WinorLoss=="L"])
xyplot(NGames ~ StreakNo, data=summarybystreak, groups=WinorLoss)
NumStreaksGreaterthan4<-sum(summarybystreak$NGames>4)
}