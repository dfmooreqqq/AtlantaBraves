library(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
    
    # Application title
    headerPanel("Atlanta Braves Season Explorer"),
    
    sidebarPanel(
        p("Please be patient while the data loads..."),
        
        selectInput("Season", "Season:",
                    list(
                        "1975" = "1975",
                        "1976" = "1976",
                        "1977" = "1977",
                        "1978" = "1978",
                        "1979" = "1979",
                        "1980" = "1980",
                        "1982" = "1982",
                        "1983" = "1983",
                        "1984" = "1984",
                        "1985" = "1985",
                        "1986" = "1986",
                        "1987" = "1987",
                        "1988" = "1988",
                        "1990" = "1990",
                        "1991" = "1991",
                        "1992" = "1992",
                        "1993" = "1993",
                        "1994" = "1994",
                        "1995" = "1995",
                        "1996" = "1996",
                        "1997" = "1997",
                        "1998" = "1998",
                        "1999" = "1999",
                        "2000" = "2000",
                        "2001" = "2001",
                        "2003" = "2003",
                        "2004" = "2004",
                        "2005" = "2005",
                        "2006" = "2006",
                        "2007" = "2007",
                        "2008" = "2008",
                        "2009" = "2009",
                        "2010" = "2010",
                        "2011" = "2011",
                        "2012" = "2012",
                        "2013" = "2013",
                        "2014" = "2014",
                        "2015" = "2015"
                         )
                    ),
        h4("How to Use This Page"),
        p("Please select a year from 1975 - 2015 from the selection above."),
        p("The charts to the right will update with the Win/Loss numbers for that season, as well as the trend throughout the season (given in number of games over .500)"),
        p("The third chart on the right shows, in the y-axis, the number of games within a streak (which is numbered on the x-axis). A streak is defined as any stretch of games that are either all wins or all losses. For example, 2 wins in a row and then a loss and then another win would define a streak of 2 wins, a streak of 1 loss, and a streak of 1 win."),
        p("The fourth chart shows the distribution of the streak lengths throughout the season."),
        p("Source of data: MLB"),
        a("Data file", href="http://www.danielfmoore.com/stats/fullteamschedule.csv"),
        p(),
        hr(),
        p("Daniel Moore"),
        a("Email", href="mailto:dfmjunk-at-notreal.com")
        
        ),
    
    mainPanel(
        h3(textOutput("Season")),
        
        p(textOutput("NoteOnSeason")),
        
        plotOutput("WLHistogram"),
        
        plotOutput("Over500Plot"),
        
        #dataTableOutput('Wquantiles'),
        
        #dataTableOutput('Lquantiles'),
        
        plotOutput("streakxyplot"),
        
        plotOutput("streakhist")
        
        )
))