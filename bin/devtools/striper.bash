#!/bin/bash
#
# Bash script to parse webix_icon css file and strip off garbage and creates html page with
# icons.
#
# output file: /tmp/icons.html
#
# Update: it turned out that I can simply go http://fontawesome.io/
#
WEBIX_HOME=../../web/webix
rsync -vru ${WEBIX_HOME} /tmp
cat ${WEBIX_HOME}/skins/air.css | grep -- "^.fa-" | cut -d':' -f1 | cut -d'{' -f1 > /tmp/icons.txt
cat top.txt > /tmp/icons.html
for i in $(cat /tmp/icons.txt); do echo "<a href='#' title='$i'><span class='webix_icon ${i:1}'></span></a>"; done >> /tmp/icons.html

cat tail.txt >> /tmp/icons.html
