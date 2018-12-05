#!/usr/bin/Rscript
# ENABLE command line arguments

rm(list=ls())

library(httr)		# used to download Teletext images
library(lubridate)	# deals with dates
library(base64enc)	# not used anymore?
library(twitteR)	# obvious
library(caTools)	# not used anymore?
library(png)		# deals with PNG
library(tesseract)	# OCR
library(stringr)	# split expressions

## choose a working directory 
# setwd()

## initialisation (uncomment/comment: only the first time!)
# a <- GET("http://api.teletext.ch/online/pics/medium/RTSUn_103-0.gif")
# crea <- dmy_hms(a$headers$'x-server-createdate')
# cat(as.character(crea), file="lastdate.txt")

## informations about the current page 103
url <- "http://api.teletext.ch/online/pics/medium/RTSUn_103-0.gif"
a <- GET(url)

## is it a new one or an old one?
crea.new <- dmy_hms(a$headers$'x-server-createdate')
crea.old <- ymd_hms(readLines("lastdate.txt", warn=F))

## if a new one, then…
if (crea.new != crea.old) {
	
	## record your Twitter app
	api_key <- ""
	api_secret <- ""
	access_token <- ""
	access_token_secret <- ""

	## callback url http://127.0.0.1:1410

	## authentication
	options(httr_oauth_cache=TRUE) 
	setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)

	## we download the image
	download.file(url, "hey.gif")

	## you need to have ImageMagick installed in order to use "convert"
	system("convert -verbose -coalesce hey.gif hey.png")

	## we add columns to the left and the right in order to fit in Twitter format
	d <- readPNG("hey.png")
        d <- d[,,1:3]

	## hey2.png must be manually created during the initialisation phase
	d2 <- readPNG("hey2.png")
        d2 <- d2[,,1:3]

	## debug
	# test_value <- sum(d != d2) / length(d)
  	# cat("\nLe pourcentage de pixels différents est de ", test_value, "\n")
        
	## if the pages are different but that not that much,
	## it probably means that a misspell has been corrected
	## in that case we delete the last status before going on
	if (sum(d != d2) / length(d) > 0 && sum(d != d2) / length(d) < .03) {
		deleteStatus(userTimeline("teletextch", 1)[[1]])
	}

	## if the current page is a new one or a corrected one, we post it
	if (sum(d != d2) != 0) {	
		
		## let's replace hey2.png for comparison next time
		writePNG(d,"hey2.png")			
		
		## we remove the first two lines for the OCR
		writePNG(d[42:460,,],"hey3.png")
		
		## the OCR
		txt <- ocr("hey3.png")
		
		## post tweet
		updateStatus(str_split(txt, "\n")[[1]][1], mediaPath="hey2.png")
	}
	
	## update the date
	cat(as.character(crea.new), file="lastdate.txt")	
}
