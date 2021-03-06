FROM rocker/shiny-verse:latest
FROM python:3.7.11

WORKDIR /usr/local/bin


RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev 

RUN apt-get update && \
    apt-get upgrade -y

RUN sudo apt-get install software-properties-common -y
RUN sudo apt install dirmngr gnupg apt-transport-https ca-certificates software-properties-common -y
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/' -y
RUN sudo apt install r-base -y

RUN sudo apt install default-jre -y
RUN sudo apt install default-jdk -y

RUN R -e "install.packages('shinydashboard', repos='http://cran.rstudio.com/')"
RUN sudo apt-get install r-cran-raster -y
RUN sudo apt-get install r-cran-devtools -y
RUN sudo apt-get install r-cran-magrittr -y
RUN R -e "install.packages(pkgs=c('shiny' ,'shinyjs' ,'shinyBS' ,'plotly' ,'shinythemes' ,'shinycssloaders' ,'RColorBrewer' ,'data.table' ,'tidyverse' ,'readr' ,'stringr' ,'BatchGetSymbols' ,'plyr' ,'reshape2' ,'rsconnect' ,'pracma' ,'ggthemes' ,'lubridate' ,'GGally' ,'ggplot2' ,'viridis' ,'fPortfolio' ,'timeSeries' ,'dplyr' ,'dygraphs' ,'xts' ,'caret' ,'rpart.plot' ,'reticulate' ,'rjson','leaflet' ,'GetDFPData'), repos='https://cran.rstudio.com/')"
RUN sudo apt-get install r-cran-rjava -y
RUN sudo apt-get install r-cran-plotrix -y
RUN sudo apt-get install r-cran-fportfolio -y





COPY . .

RUN python -m pip install --upgrade pip
RUN pip install -r requirements.txt


EXPOSE 3838
CMD ["R", "-e", "shiny::runApp('/usr/local/bin', host = '0.0.0.0', port = 3838)"]
