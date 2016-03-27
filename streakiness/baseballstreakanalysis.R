# Set working directory
workingdir<-paste("C:\\Users", Sys.getenv("USERNAME"), "Documents\\GitHub\\AtlantaBraves\\streakiness", sep = "\\")
setwd(workingdir)
# Load packages.
packages <- c("plyr", "lattice", "data.table", "ggplot2", "sm", "forecast")
packages <- lapply(packages, FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
        install.packages(x)
        library(x, character.only = TRUE)
    }
})

yearlist<-c(1975:1980, 1982:1988, 1990:2001, 2003:2014)

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
fullteamschedule<-fullteamschedule[fullteamschedule$Year!=2002,]
fullteamschedule$StreakNo[1]<-1
fullteamschedule$Over500[1]<- -1
fullteamschedule$Count <- 1
for(i in 2:length(fullteamschedule$WinorLoss)){
    if(fullteamschedule$WinorLoss[i]==fullteamschedule$WinorLoss[i-1]){
        fullteamschedule$StreakNo[i]<-fullteamschedule$StreakNo[i-1]
    }
    else {
        fullteamschedule$StreakNo[i]<-fullteamschedule$StreakNo[i-1]+1
    }
    if(fullteamschedule$WinorLoss[i]=="W"){
        fullteamschedule$Over500[i]<-fullteamschedule$Over500[i-1]+1
    }
    else {
        fullteamschedule$Over500[i]<-fullteamschedule$Over500[i-1]-1
    }
    if(fullteamschedule$Year[i]!=fullteamschedule$Year[i-1]){
        fullteamschedule$StreakNo[i]<-1
        if(fullteamschedule$WinorLoss[i]=="W"){
            fullteamschedule$Over500[i]<- 1
        }
        else {
            fullteamschedule$Over500[i]<- -1
        }
    }
}






summarybystreak <- ddply(fullteamschedule, .(StreakNo, WinorLoss, Year), summarize, NGames=sum(Count))
#histogram( ~ summarybystreak$NGames | summarybystreak$Year*summarybystreak$WinorLoss, nint=max(summarybystreak$NGames, na.rm=TRUE))
Wquantiles<-quantile(summarybystreak$NGames[summarybystreak$WinorLoss=="W"])
Lquantiles<-quantile(summarybystreak$NGames[summarybystreak$WinorLoss=="L"])
xyplot(NGames ~ StreakNo, data=summarybystreak, groups=WinorLoss)
StreakLength<-4
NumLongStreaksWL<-ddply(summarybystreak, .(Year, WinorLoss), summarize, LongStreaks = sum(NGames>StreakLength), LongStreakPerc = sum(NGames[NGames>StreakLength])/162)
NumLongStreaks<-ddply(summarybystreak, .(Year), summarize, LongStreaks = sum(NGames>StreakLength), LongStreakPerc = sum(NGames[NGames>StreakLength])/162)
xyplot(LongStreaks~Year, data = NumLongStreaks)

xyplot(Over500~as.numeric(Gm.)|Year, data=fullteamschedule[fullteamschedule$Year=="1993",])
qplot(fullteamschedule[fullteamschedule$Year=="1993",]$WinorLoss, xlab="Win or Loss", ylab="Total Number")
qplot(as.numeric(Gm.), Over500, data=fullteamschedule[fullteamschedule$Year=="1993",], xlab="Game of Season", ylab="Number of games above or below .500", color=StreakNo) + geom_hline(aes(yintercept=0), colour="#990000", linetype="dashed")


write.csv(fullteamschedule, "fullteamschedule.csv")

library(sm)
sm.density.compare(NGames, Year, data=summarybystreak)


### time series fitting - see here - https://www.otexts.org/fpp/8/7
library("forecast", lib.loc="~/R/win-library/3.1")
a<-fullteamschedule[fullteamschedule$Year=="2014",]$Over500
fit<-auto.arima(a)
summary(fit)
plot(forecast(fit))


testa<-a[1:81]
validatea<-a[82:length(a)]
fit1<-auto.arima(testa)
predictmore<-predict(fit1, n.ahead=validatea, newxreg=82:(length(a)))
predictmore<-as.data.frame(predictmore)
predictmore$upper95<-predictmore$pred + 1.96 * predictmore$se
predictmore$lower95<-predictmore$pred - 1.96 * predictmore$se

predictmore$upper68<-predictmore$pred + 1 * predictmore$se
predictmore$lower68<-predictmore$pred - 1 * predictmore$se


plot(forecast(fit1, h=length(validatea)))
lines(82:length(a),validatea, col="red")
lines(82:length(a),predictmore$upper95, col="green")
lines(82:length(a),predictmore$lower95, col="green")

lines(82:length(a),predictmore$upper68, col="blue")
lines(82:length(a),predictmore$lower68, col="blue")

