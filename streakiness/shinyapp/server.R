library(shiny)

# Let's load the full season csv from the github depository
### Need to find a host for the data
fullteamschedule<-read.csv("C:\\Users\\Daniel\\Documents\\GitHub\\AtlantaBraves\\streakiness\\teamschedule.csv")

summarybystreak <- ddply(fullteamschedule, .(StreakNo, WinorLoss, Year), summarize, NGames=sum(Count))
Wquantiles<-quantile(summarybystreak$NGames[summarybystreak$WinorLoss=="W"])
Lquantiles<-quantile(summarybystreak$NGames[summarybystreak$WinorLoss=="L"])

StreakLength<-4
NumLongStreaksWL<-ddply(summarybystreak, .(Year, WinorLoss), summarize, LongStreaks = sum(NGames>StreakLength), LongStreakPerc = sum(NGames[NGames>StreakLength])/162)
NumLongStreaks<-ddply(summarybystreak, .(Year), summarize, LongStreaks = sum(NGames>StreakLength), LongStreakPerc = sum(NGames[NGames>StreakLength])/162)

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
    
})