#!/usr/bin/Rscript
# ENABLE command line arguments

rm(list=ls())

library(httr)
library(lubridate)
library(base64enc)
library(twitteR)
library(caTools)
library(png)

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

	## authentification
	options(httr_oauth_cache=TRUE) 
	setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)

	## we download the image
	download.file(url, "hey.gif")
	a <- read.gif("hey.gif", frame=1)

	## convert it from a .gif to a .png
	## convert comes from imageMagick
	system("/opt/local/bin/convert -verbose -coalesce hey.gif hey.png")

	## we add columns to the left and the right in order to fit in Twitter format
	b <- readPNG("hey.png")
	d <- array(0, dim=c(460, 840, 3))
	for (i in 1:3) d[,,i] <- cbind(matrix(as.integer(0), nrow=460, ncol=100), b[,,i], matrix(as.integer(0), nrow=460, ncol=100))
	
	## we remove the last two lines (with advertisements)
	d <- d[1:418,,]
	
	d2 <- readPNG("hey2.png")

	# if the pages are different but that not that much, it probably means that a misspell has been corrected
	# in that case we delete the last status before going on
	if (sum(abs(d-d2)) / length(d) > 0 & sum(abs(d-d2)) / length(d) < .03) {
		us <- getUser("teletextch")
		deleteStatus(userTimeline("teletextch", 1)[[1]])
	}

	# if you wanna test the condition above :
	# test1 <- readPNG("test1.png")
	# test2 <- readPNG("test2.png")
	
	# let's replace hey2.png for comparison next time
	writePNG(d ,"hey2.png")
	updateStatus("", mediaPath="hey2.png")
	
	## and let's save the date to compare next time!
	cat(as.character(crea.new), file="lastdate.txt")	
}
