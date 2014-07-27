# server.R


library("shiny")
#library('devtools')
#install_github('shiny-incubator', 'rstudio')
library("shinyIncubator")
library("lubridate")
library("ggplot2")
library('plyr')
library('RODBC')
library('MASS')
# initialize data areaPrices and



## Calculate the hour price regresed on the last 21 days and create peak/offPeak coeficients
SpotPricesXarea <- read.table("data/SpotPricesXarea.txt",header = TRUE, sep = ";")
mods <- dlply(SpotPricesXarea, .( Weekend, hour, area), lm, formula = spot ~ spotAvg )
coefsSpotShortTermTemp <- as.data.frame(ldply(mods, coef), col.names=c( 'Weekend','hour','area','intercept','slope'))
coefsSpotShortTermTemp$peak <- 0
coefsSpotShortTermTemp$peak[coefsSpotShortTermTemp$Weekend == 0 & coefsSpotShortTermTemp$hour >= 8 & coefsSpotShortTermTemp$hour < 20] <- 1


## Fetch current forward market for the comming week
## Pseudocode for this piece
calcDates <- c(format(Sys.Date() + seq(1:7),format = "%a %d-%b"))
forwards <- c(27,36,29,30,29,34,29,34)
rndFactor <- rnorm(56,mean = 1,sd = 0.05)
areaPrice <- cbind(calcDates ,data.frame(matrix(forwards*rndFactor, 7, 8)))

colnames(areaPrice) <- c("date","EPEX Base", "EPEX Peak","NO2 Base", "NO2 Peak","SE3 Base", "SE3 Peak","SE4 Base", "SE4 Peak")
rownames(areaPrice)<-calcDates



shinyServer(
  function(input, output) {
    # table of outputs
#     calcDates <- c(format(Sys.Date() + ddays(seq(1:7)),format = "%a %d-%b"))
#     areaPrice <- cbind(calcDates ,data.frame(matrix(rep(1,56), 7, 8)))
#     colnames(areaPrice) <- c("date","EPEX Base", "EPEX Peak","NO2 Base", "NO2 Peak","SE3 Base", "SE3 Peak","SE4 Base", "SE4 Peak")
#     rownames(areaPrice)<-calcDates
#     input <- NULL
#     input$forwardExp <- areaPrice
    output$table.output <- renderTable(
{ res <- matrix(apply(input$forwardExp[,2:5],1,prod))
  res <- do.call(cbind, list(input$forwardExp[,1:5], res))
  colnames(res) <- c("Input 1","Input 2","Product","Input 2","Product1","Product2")
  format(res,digits = 2, nsmall = 2)
}
, include.rownames = TRUE
, include.colnames = TRUE
, align = "lcccccc"
, digits = 3
, sanitize.text.function = function(x) x
    )
  }
)
