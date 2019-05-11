library(rvest)
library(glue)
library(dplyr)
library(magrittr)


path = 'Books/Dungeons & Dragons/D&D 5th Edition'
path = 'Books/Dungeons and Dragons/3rd Party/5th Edition'


getFiles = function(path,overwrite=FALSE,sleep = 1){
    dir.create(path,recursive = TRUE,showWarnings = FALSE)
    
    
    rootURL = paste0('https://thetrove.net/',URLencode(path))
    print(path); flush.console()
    rootPage = NULL
    
    while(is.null(rootPage)){
        rootPage = tryCatch(read_html(rootURL),error = function(e){
            NULL
        })
        if(is.null(rootPage)){
            print('whops failed'); flush.console()
            Sys.sleep(sleep)
            print('respectfully waited'); flush.console()    
        }
    }
    
    directories = rootPage %>% html_nodes('.dir')
    files = rootPage %>% html_nodes('.file')
    
    
    files %>% html_attrs() %>% purrr::map_chr('onclick') %>% 
        stringr::str_extract("(?<=href\\='\\.).*?(?=')") %>% 
        lapply(function(fileRelLink){
            filepath = file.path(path,URLdecode(fileRelLink))
            # print(filepath)
            if(file.exists(filepath) && !overwrite){
                return(FALSE)
            }
            print('waiting before download'); flush.console()
            fileURL = file.path(rootURL,fileRelLink)
            Sys.sleep(sleep)
            print('downloading'); flush.console()
            download.file(fileURL,filepath,mode = 'wb')
        })
    
    Sys.sleep(sleep)
    
    directories %>%
        html_attrs %>%
        purrr::map_chr('onclick') %>%
        stringr::str_extract("(?<=href\\=').*?(?=')") %>%
        {.[.!='../index.html']} %>% lapply(function(dirRelLink){
            dirpath = file.path(path,URLdecode(dirRelLink))
            getFiles(dirpath)
            Sys.sleep(sleep)
        })
}

getFiles(path = path,sleep = 60)
