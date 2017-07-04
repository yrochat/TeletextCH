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

setwd("~/Documents")	# set working directory

# init
# a <- GET("http://api.teletext.ch/online/pics/medium/RTSUn_103-0.gif")
# crea <- dmy_hms(a$headers$'x-server-createdate')
# cat(as.character(crea), file="lastdate.txt")

url <- "http://api.teletext.ch/online/pics/medium/RTSUn_103-0.gif"

a <- GET(url)

crea.new <- dmy_hms(a$headers$'x-server-createdate')
crea.old <- ymd_hms(readLines("lastdate.txt", warn=F))

if (crea.new != crea.old) {
	api_key <- "IrMThyoZg8ZDvfVJuXuOmTeDT"
	api_secret <- "vgviFBqJBWFtq4LCMVyoGyv1oCfkhB50Ay55GoaY1LpdGLITyP"
	access_token <- "4241462379-Hhyom0kKDn5Uk0RXgN3yXsTDGE95KQi7qkC2zZs"
	access_token_secret <- "vjYmff9Ztq8OZ6fvQ9UKXNmdKhDWctvTY5FfMGa63p4Cz"
	# callback url http://127.0.0.1:1410

	options(httr_oauth_cache=TRUE) 
	setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)

	download.file(url, "hey.gif")

	# you need to have ImageMagick installed in order to use "convert"
	system("convert -verbose -coalesce hey.gif hey.png")

	d <- readPNG("hey.png")
        d <- d[,,1:3]

	d2 <- readPNG("hey2.png")
        d2 <- d2[,,1:3]

	test_value <- sum(d != d2) / length(d)
  	cat("\nLe pourcentage de pixels différents est de ", test_value, "\n")
        
	if (sum(d != d2) / length(d) > 0 && sum(d != d2) / length(d) < .03) {
		deleteStatus(userTimeline("teletextch", 1)[[1]])
	}

	if (sum(d != d2) != 0) {	
		writePNG(d,"hey2.png")			
		writePNG(d[42:460,,],"hey3.png")	# remove the first two lines
		txt <- ocr("hey3.png")			# OCR
		updateStatus(str_split(txt, "\n")[[1]][1], mediaPath="hey2.png")
	}
	
	cat(as.character(crea.new), file="lastdate.txt")	
}






