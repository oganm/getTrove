library(rvest)
library(glue)
library(dplyr)
library(magrittr)


path = 'Books/Dungeons & Dragons/D&D 5th Edition'


getFiles = function(path){
    dir.create(path,recursive = TRUE,showWarnings = FALSE)
    
    
    rootURL = paste0('https://thetrove.net/',URLencode(path))
    rootPage = read_html(rootURL)
    
    
    
    directories = rootPage %>% html_nodes('.dir')
    files = rootPage %>% html_nodes('.file')
    
    
    files %>% html_attrs() %>% purrr::map_chr('onclick') %>% 
        stringr::str_extract("(?<=href\\='\\.).*?(?=')") %>% 
        lapply(function(fileRelLink){
            filepath = file.path(path,URLdecode(fileRelLink))
            fileURL = file.path(rootURL,fileRelLink)
            download.file(fileURL,filepath)
        })
    
    
    directories %>%
        html_attrs %>%
        purrr::map_chr('onclick') %>%
        stringr::str_extract("(?<=href\\=').*?(?=')") %>%
        {.[.!='../index.html']} %>% lapply(function(dirRelLink){
            dirpath = file.path(path,URLdecode(dirRelLink))
            getFiles(dirpath)
        })
}

getFiles(path = path)
