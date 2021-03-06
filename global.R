## Load packages
library("rJava")
library("shiny")
library("shinyjs")
library("shinyBS")
library("plotly")
library("shinythemes")
library("shinycssloaders")
library("RColorBrewer")
library("data.table")
library("tidyverse")
library("readr")
library("stringr")
library("BatchGetSymbols")
library("GetDFPData")
library("plyr")
library("reshape2")
library("rsconnect")
library("pracma")
library("ggthemes")
library("lubridate")
library("GGally")
library("ggplot2")
library("viridis")
library("fPortfolio")
library("timeSeries")
library("dplyr")
library("plotrix")
library("dygraphs")
library("xts")
library("shinydashboard")
library("caret")
library("rpart.plot")
#library("reticulate")
#devtools::install_github("rstudio/reticulate")
library('reticulate')
library('rjson')

#setwd('/srv/shiny-server/Shiny')

options(DT.options = list(scrollY="300px",scrollX="300px", 
                          pageLength = 100, 
                          columnDefs = list(list(className = 'dt-center', targets = "_all"))))



i <- 0
DI = '2015-01-01' #Data de inicio
DF = Sys.Date() #Data de fim(hoje)
benchmark = '^BVSP' #indice da bolsa



montaCandles <- function(acao){
  candlesDB = BatchGetSymbols(
    tickers = acao, #Especificando as ações
    first.date = DI,
    last.date= DF,
    bench.ticker = benchmark)
  #Pegando o segundo elemento da lista retornada, que e o que contem os dados.
  candlesDB = candlesDB$df.tickers
  i <- list(line = list(color = '#00FF00'))
  d <- list(line = list(color = '#FF0000'))
  #Selecao de colunas de interesse
  candlesDB <- candlesDB %>% select(c(1,2,3,4,7,8))
  candlesDB$variation <- abs(candlesDB$price.high-candlesDB$price.low)
  candlesDB <- tail(candlesDB, 30) #Ultimos 30 dias
  
  names(candlesDB)[5] <- c("Data")
  fig <- candlesDB %>% plot_ly(x = ~Data, type="candlestick",
                               open = ~price.open, close = ~price.close,
                               high = ~price.high, low = ~price.low, increasing = i, decreasing = d
                               ) 
  fig <- fig %>% layout(title = "Gráfico de Candles dos Últimos 30 Dias",yaxis = list(title = "Preço"),legend = list(orientation = 'h', x = 0.5, y = 1,
                                                                                                         xanchor = 'center', yref = 'paper',
                                                                                                         font = list(size = 10),
                                                                                                         bgcolor = 'transparent'))
  
  
  fig
    
  }


montaBDAcoes <- function(acao){
 
    IBOVdatabase = BatchGetSymbols(
      tickers = acao, #Especificando as ações
      first.date = DI,
      last.date= DF,
      bench.ticker = benchmark)
    
    
    #Pegando o segundo elemento da lista retornada, que e o que contem os dados.
    IBOVdatabase = IBOVdatabase$df.tickers
    
    #Selecao de colunas de interesse
    IBOVdatabase <- IBOVdatabase %>% 
      select(-c(5,9,10))
    #Estrutura do banco de dados
    str(IBOVdatabase)
    #Lista com varios dataframes de acordo com as acoes presentes em IBOVdatabase
    IBOVdatabase = dlply(IBOVdatabase,.(ticker),function(x){rownames(x)=x$row;x$row=NULL;x}) 
    #Resumir o Banco de Dados
    BancoDeDados_Acoes = IBOVdatabase[[1]][,c(6,5)] #Extrair as colunas 7 e 6 do dataframe 1
    
    colnames(BancoDeDados_Acoes) = c("Data",paste(IBOVdatabase[[1]][1,7])) #Renomeando as colunas
    #teste <- IBOVdatabase[[1]]
    #print(length(acao))
    if(length(acao)>1){
    for(i in 2:length(IBOVdatabase)){
      
      itera_BancoDeDados_Acoes = IBOVdatabase[[i]][,c(6,5)] 
      colnames(itera_BancoDeDados_Acoes) = c("Data",paste(IBOVdatabase[[i]][1,7])) #Renomeando as colunas
      BancoDeDados_Acoes = merge(BancoDeDados_Acoes,itera_BancoDeDados_Acoes, by = "Data") #Juntando os dataframes usando a Data como coluna chave para fazer os joins.
    }
      rm(itera_BancoDeDados_Acoes)
      
      
}

  return (BancoDeDados_Acoes)
}

acoesDisponiveis <- c("ABEV3.SA" , "B3SA3.SA" , "BBAS3.SA",  "BBDC3.SA"  ,"BBDC4.SA" , "BBSE3.SA", 
                      "BEEF3.SA"  ,"BRAP4.SA"  ,"BRFS3.SA" , "BRKM5.SA"  ,"BRML3.SA"  , "CCRO3.SA" ,
                      "CIEL3.SA"  ,"CMIG4.SA"  ,"COGN3.SA" , "CPFE3.SA" , "CPLE6.SA",  "CSAN3.SA",  "CSNA3.SA", 
                      "CVCB3.SA"  ,"CYRE3.SA"  ,"ECOR3.SA"  ,"EGIE3.SA" , "ELET3.SA",  "ELET6.SA",  "EMBR3.SA", 
                      "ENBR3.SA"  ,"ENEV3.SA"  ,"ENGI11.SA" ,"EQTL3.SA" , "EZTC3.SA",  "FLRY3.SA",  "GGBR4.SA", 
                      "GOAU4.SA"  ,"GOLL4.SA"  ,"HYPE3.SA" ,  "ITSA4.SA",  "ITUB4.SA", 
                      "JBSS3.SA"  ,"JHSF3.SA"  ,"KLBN11.SA" ,"LAME4.SA"  ,"LCAM3.SA",  "LREN3.SA",  "MGLU3.SA", 
                      "MRFG3.SA"  ,"MRVE3.SA"  ,"MULT3.SA"  ,"PCAR3.SA"  ,"PETR3.SA",  "PETR4.SA",  "PRIO3.SA", 
                      "QUAL3.SA"  ,"RADL3.SA"  ,"RAIL3.SA"  ,"RENT3.SA"  ,"SANB11.SA", "SBSP3.SA",  "SULA11.SA",
                      "SUZB3.SA"  ,"TAEE11.SA" ,"TIMS3.SA"  ,"TOTS3.SA"  ,"UGPA3.SA",  "USIM5.SA",  "VALE3.SA" ,
                      "VIVT3.SA"  ,"WEGE3.SA"  ,"YDUQ3.SA" )


##Teste

##Banco de Dados mais apurado com descrição e os tickers. 
df_emp <-  GetDFPData::gdfpd.get.info.companies()
df_emp <-  df_emp %>% select(c(1,11:14))
#Tirar os duplicados
df_emp <-  df_emp[!duplicated(df_emp), ]
#Tirar as empresas que nao tem um pregao
df_emp <- df_emp %>% dplyr::filter(tickers!="")
names(df_emp) = c("Nome","Setor","Subsetor","Segmento","Tickers")
#Remover espacos entre as strings
df_emp$Nome    <- str_squish(df_emp$Nome    )
df_emp$Setor   <- str_squish(df_emp$Setor   )
df_emp$Subsetor<- str_squish(df_emp$Subsetor)
df_emp$Segmento<- str_squish(df_emp$Segmento)
df_emp$Tickers <- str_squish(df_emp$Tickers )
df_emp$Nome    <- str_trim(df_emp$Nome    )
df_emp$Setor   <- str_trim(df_emp$Setor   )
df_emp$Subsetor<- str_trim(df_emp$Subsetor)
df_emp$Segmento<- str_trim(df_emp$Segmento)
df_emp$Tickers <- str_trim(df_emp$Tickers )
#Colocar em caixa alta
df_emp$Nome    <- str_to_upper(df_emp$Nome    )
df_emp$Setor   <- str_to_upper(df_emp$Setor   )
df_emp$Subsetor<- str_to_upper(df_emp$Subsetor)
df_emp$Segmento<- str_to_upper(df_emp$Segmento)
df_emp$Tickers <- str_to_upper(df_emp$Tickers )

tema <- theme(plot.title = element_text(family = "Helvetica", face = "bold", size = (15)), 
              legend.title = element_text(colour = "steelblue",  face = "bold.italic", family = "Helvetica"), 
              legend.text = element_text(face = "italic", colour="steelblue4",family = "Helvetica"), 
              axis.title = element_text(family = "Helvetica", size = (10), colour = "steelblue4"),
              axis.text = element_text(family = "Courier", colour = "cornflowerblue", size = (10))) 

#saveRDS(BancoDeDados_Acoes,"BancoDeDados_Acoes.rds")

listaTodosSetores <- function(df_emp){
  setores = subset(df_emp, select = c(2))
  setores = setores[!duplicated(setores),]
  return(setores)
}
listaSetores  <- listaTodosSetores(df_emp)

verificar_coluna <- function(data, coluna){
  retorno <- coluna
  retorno %in% data
}

listaAcoesUmSetor <- function(df_emp,setorMonitorado){
  setor = setorMonitorado
  #Pegar todas as empresas desse setor
  Acoes_Filtradas = subset(df_emp,df_emp[2]==setor)
  #Pegar todos os tickers dessas empresas desse setor
  Acoes_Filtradas_lista = Acoes_Filtradas$Tickers
  nlinhas <- nrow(Acoes_Filtradas)
  lista <- ""
  pos <- 1L
  #Pegando a coluna "Data" do BancoDeDados_Acoes para fazer um join depois
  #Vamos conferir quais  os tickers desse BD Auxiliar(no setor escolhido) estao no BD do Yahoo.
  for(i in 1:nlinhas){
    tickers = strsplit(Acoes_Filtradas_lista[i],";")
    for (j in 1:length(tickers[[1]])){
      aux <- paste(tickers[[1]][j],"SA",sep=".")
      if (verificar_coluna(acoesDisponiveis,aux)){
        #df_setor[aux] =  select(BancoDeDados_Acoes,aux)
        lista[pos] <- aux
        pos = pos+1
      }
      
    }
    
  }
 
  return(lista)
  
}
#listaAcoesUmSetor(df_emp,"SAÚDE")

listaSemB3 <- function(){
  acoes <- acoesDisponiveis[acoesDisponiveis!="B3SA3.SA"]
  return(acoes)
}
noB3 <- listaSemB3()

#bimestres <- c("Janeiro/Fevereiro","Março/Abril","Maio/Junho","Julho/Agosto","Setembro/Outubro","Novembro/Dezembro")
bimestres <- c(1,2,3,4,5,6)
anoAtual <- strsplit(as.character(Sys.Date()),"-")[[1]][1]
anos <- 2016:anoAtual
secoes <- c("Apresentação","Ativo Único", "Setorial Completo", "Setorial Filtrado", "Sobre os Envolvidos")

createDataSet <- function(acao){
  DI = '2015-01-01' #Data de inicio
  DF = Sys.Date() #Data de fim(hoje)
  benchmark = '^BVSP' #indice da bolsa
  DataSet = BatchGetSymbols(
    tickers = acao, #Especificando as ações
    first.date = DI,
    last.date= DF,
    bench.ticker = benchmark)
  
  
  #Pegando o segundo elemento da lista retornada, que e o que contem os dados.
  DataSet = DataSet$df.tickers
  
  #Selecao de colunas de interesse
  # DataSet <- DataSet %>% 
  #    select(c(1,2,3,4,7,8))
  
  
  
  DataSet <- createMetrics(DataSet)
  
  return (DataSet)
}

createMetrics <- function (DataSet){
  DataSet$price.highLow <- DataSet$price.high - DataSet$price.low
  DataSet <- data.table(DataSet)
  DataSet[ , `:=`(
    ret.adjusted.prices = fcase(
      is.na(ret.adjusted.prices),0,
      ret.adjusted.prices=!is.na(ret.adjusted.prices),ret.adjusted.prices
    ),
    ret.closing.prices = fcase(
      is.na(ret.closing.prices),0,
      ret.closing.prices != is.na(ret.closing.prices),ret.closing.prices
    )
  )
  
  ]
  DataSet$price.hype <- DataSet$price.high - DataSet$price.open
  return (DataSet)
  
  
}

normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}
