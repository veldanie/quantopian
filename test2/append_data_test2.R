
#Set working directory:
setwd("/Users/veldanie/Documents/bgse/Quantopian/test2/csvfiles")
library(tibble)

# Years: 
years=2002:2012
library(dplyr)
# File prefix:
fname1 <- 'Data_Sort_RL1_MDR_NYSE_1_'
fname10 <- 'Data_Sort_RL1_MDR_NYSE_10_'
#Append portfolio for each date:
portfolio = c()
trade_month = '07'
file.remove('../portafolio.csv')
symbols <- c()
for (y in years){
  date_y <- paste0(trade_month,'-','01','-', y)
  raw_data1 <- read.csv(paste0(fname1,y,'.csv'), header = TRUE)
  raw_data10 <- read.csv(paste0(fname10,y,'.csv'), header = TRUE)
  raw_data10$Weight <- -raw_data10$Weight #Short portfolio 10.
  raw_data <- rbind(raw_data1,raw_data10)
  symbols <- unique( c(symbols, as.character(raw_data$Symbol)))
  weights <- raw_data$Weight[match(symbols, raw_data$Symbol)]; weights[is.na(weights)] <- 0
  port_y <- tibble(date = date_y, symbol = symbols, weight = weights)
  portfolio <- rbind(portfolio, port_y)
}

# Adjust tickers if neccesary using the equivalences in table equiv:
equiv <- read.table('../equiv.csv', header=TRUE, sep = ',', colClasses = 'character')
ticker_rep <- equiv$quantopian[match(portfolio$'symbol',equiv$file)]
portfolio[which(!is.na(ticker_rep)),'symbol']=ticker_rep[which(!is.na(ticker_rep))]

#Create file to feed to QUantopian:
write.table(portfolio, '../portfolio.csv', sep = ',', col.names = TRUE, row.names = FALSE, quote = FALSE)


##Check portfolio of a specific data:
library(dplyr)
target_date <- '07-01-2014'
port_date <- portfolio %>% filter(date == target_date & weight >0) %>% select(symbol)
print(port_date)


##Validate ticker:
library(quantmod)
stocks <- stockSymbols()

ticker <- 'BRK.A'
print(stocks %>% filter(Symbol == ticker))
print(getSymbols(ticker,from=target_date))

