library(shiny); library(ggplot2); library(lattice);

# Let's load the full season csv from the github depository
### Need to find a host for the data
fullteamschedule<-read.csv("C:\\Users\\damoore\\Documents\\GitHub\\AtlantaBraves\\streakiness\\fullteamschedule.csv")
fullteamschedule$GameNo<-as.numeric(as.character(fullteamschedule$Gm.))

yearnotes<-read.csv("C:\\Users\\damoore\\Documents\\GitHub\\AtlantaBraves\\streakiness\\yearnotes.csv")


summarybystreak <- ddply(fullteamschedule, .(StreakNo, WinorLoss, Year), summarize, NGames=sum(Count))

StreakLength<-4
NumLongStreaksWL<-ddply(summarybystreak, .(Year, WinorLoss), summarize, LongStreaks = sum(NGames>StreakLength), LongStreakPerc = sum(NGames[NGames>StreakLength])/162)
NumLongStreaks<-ddply(summarybystreak, .(Year), summarize, LongStreaks = sum(NGames>StreakLength), LongStreakPerc = sum(NGames[NGames>StreakLength])/162)

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
    
    #Render Year for printing as caption/header
    output$Season <- renderText({
        input$Season
    })
    

    output$NoteOnSeason <- renderText({
        as.character(yearnotes$Notes[yearnotes$Year==as.numeric(input$Season)])
    })
    
    # Generate Histogram Plot as well as amount over .500 plot
    output$WLHistogram <- renderPlot({
                                    qplot(WinorLoss, data=fullteamschedule[fullteamschedule$Year==as.numeric(input$Season),], , xlab="Win or Loss", ylab="Total Number")
                                      })
    
    output$Over500Plot <- renderPlot({
                                    qplot(GameNo, Over500, data=fullteamschedule[fullteamschedule$Year==as.numeric(input$Season),], , xlab="Game of Season", ylab="Number of games above or below .500", color=StreakNo) + geom_hline(aes(yintercept=0), colour="#990000", linetype="dashed")
                                    })
    
    output$mytable = renderDataTable({
        fullteamschedule[fullteamschedule$Year==as.numeric(input$Season),]
    })
    
    
    #output$Wquantiles<-renderDataTable({
    #                                    quantile(summarybystreak$NGames[(summarybystreak$WinorLoss=="W") & (summarybystreak$Year==as.numeric(input$Season))])
    #})
    #output$Lquantiles<-renderDataTable({
    #                                    quantile(summarybystreak$NGames[(summarybystreak$WinorLoss=="L") & (summarybystreak$Year==as.numeric(input$Season))])
    #})
    output$xyplot<-renderPlot({
                            xyplot(NGames ~ StreakNo, data=summarybystreak[summarybystreak$Year==as.numeric(input$Season)], groups=WinorLoss)
    })
    
    
    
    
})