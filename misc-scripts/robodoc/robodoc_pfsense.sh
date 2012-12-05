#!/bin/sh
#
# Script to generate the pfSense robodoc pages.

./robodoc --tell --src ./pfSense/ --doc ./pfsense_output --singledoc --sections --toc --html
mv pfsense_output.html public_html/index.html
mv pfsense_output.css public_html
