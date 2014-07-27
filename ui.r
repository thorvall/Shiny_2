
# ui.R
library('plyr')
library('RODBC')
# initialize data areaPrices and

## Fetch current forward market for the comming week
## Pseudocode for this piece, calculate comminf week dats and generate forwards
calcDates <- c(format(Sys.Date() + seq(1:7),format = "%a %d-%b"))
forwards <- c(27,38,30,34,29,35,29,35)
rndFactor <- rnorm(56,mean = 1,sd = 0.1)
areaPrice <- cbind(calcDates ,data.frame(matrix(forwards*rndFactor, 7, 8,byrow = TRUE)))

colnames(areaPrice) <- c("date","EPEX Base", "EPEX Peak","NO2 Base", "NO2 Peak","SE3 Base", "SE3 Peak","SE4 Base", "SE4 Peak")
##rownames(areaPrice)<-calcDates
areaCoeficients <-  matrix(rep(c(1,0,1),7),7 ,3, byrow = TRUE)
shinyUI(


  navbarPage(
    title = 'Trading Interface',
    tabPanel('Forward Curve',     dataTableOutput('priceComposition'), h4("TODO, Didn't finish the task, idea and final result wil be an indicator for trades regarding the expected hourly electricity prices, but look at the 'short term price model sheet' there is a reactive table from shiny-incubator")),
    tabPanel(

  "Short Term Price Model",

  fluidRow(
    column(5,
           wellPanel(
             h4("Forcasts")
             ,
             tableOutput(outputId = 'table.output')
             ,
             helpText("Hour Forecast")
           )),

    column(7,

      tabsetPanel(position = "above",
        tabPanel("Area Forward exp"
                   ,
                 matrixInput(inputId = 'forwardExp', label = 'do NOT use', data = format(areaPrice,digits = 4, nsmall = 2))

                   ,
                   helpText("Insert expected OffPeak/Peak prices for the comming week"),
                  ("PriceMix")
                 ,
                  matrixInput(inputId = 'priceComposition', label = 'Add/Remove Rows', data = as.data.frame(matrix(rep(c(1,0,1),7),7 ,3, byrow = TRUE)))
                   ,
                   helpText("x in 0 to 1, total pr area <= 1, NO2/SE4 are the residuals")

  ),
        tabPanel("Summary", verbatimTextOutput("summary")),
        tabPanel("Table", tableOutput("table"))
      )
    )
  )
)))
