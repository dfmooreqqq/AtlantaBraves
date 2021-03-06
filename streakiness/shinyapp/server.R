library(shiny); library(ggplot2); library(plyr);library(data.table);

# Let's load the full season csv from the github depository
### Need to find a host for the data
fullteamschedule<-read.csv("http://www.danielfmoore.com/stats/fullteamschedule.csv")
#fullteamschedule<-read.csv("http://github.com/dfmooreqqq/AtlantaBraves/raw/master/streakiness/fullteamschedule.csv")
fullteamschedule$GameNo<-as.numeric(as.character(fullteamschedule$Gm.))

#yearnotes<-read.csv("C:\\Users\\damoore\\Documents\\GitHub\\AtlantaBraves\\streakiness\\yearnotes.csv")
#yearnotes<-read.csv("http://github.com/dfmooreqqq/AtlantaBraves/raw/master/streakiness/yearnotes.csv")
yearnotes<-read.csv("http://www.danielfmoore.com/stats/yearnotes.csv")

summarybystreak <- ddply(fullteamschedule, .(StreakNo, WinorLoss, Year), summarize, NGames=sum(Count))

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
    
    #Render Year for printing as caption/header
    output$Season <- renderText({
        input$Season
    })
    
    currentSeason <- reactive({as.numeric(input$Season)})

    output$NoteOnSeason <- renderText({
        as.character(yearnotes$Notes[yearnotes$Year==as.numeric(input$Season)])
    })
    
    # Generate histogram plot as well as amount over .500 plot
    output$WLHistogram <- renderPlot({
                                    qplot(WinorLoss, data=fullteamschedule[fullteamschedule$Year==currentSeason(),], , xlab="Win or Loss", ylab="Total Number", fill=WinorLoss)
                                      })
    
    output$Over500Plot <- renderPlot({
                                    qplot(GameNo, Over500, data=fullteamschedule[fullteamschedule$Year==currentSeason(),], , xlab="Game of Season", ylab="Number of games above or below .500", color=StreakNo) + geom_hline(aes(yintercept=0), colour="#990000", linetype="dashed")
                                    })
    

    output$streakxyplot <- renderPlot({
                            qplot(StreakNo, NGames, data=summarybystreak[summarybystreak$Year==currentSeason(),], geom="point")
    })

    output$streakhist <- renderPlot({
        qplot(NGames, data=summarybystreak[summarybystreak$Year==currentSeason(),])+geom_histogram(binwidth=1, aes(fill = ..count..))
    })    
    
    
    
})