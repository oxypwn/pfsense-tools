#!/usr/local/bin/bash
ROOTPATH=/usr/pfsense
CVSPATH=$ROOTPATH/cvsroot
CVSROOT=:ext:username@cvs.pfsense.com:/cvsroot
WWWPATH=$ROOTPATH/wwwroot

# update from CVS
cd $CVSPATH && cvs -d $CVSROOT co docbook

# build html files
/usr/local/bin/xsltproc \
        --stringparam section.autolabel 1 \
        --stringparam section.label.includes.component.label 1 \
        --stringparam toc.max.depth 2 \
        --stringparam html.stylesheet pfsensedoc.css \
        --stringparam chunker.output.indent yes \
        --stringparam base.dir $WWWPATH/docbook/ \
        /usr/local/docbook-xsl-1.61.3/html/chunk.xsl \
        $CVSPATH/docbook/book.xml

#  copy files into place for www
cp $CVSPATH/docbook/m0n0doc.css $WWWPATH/docbook
cp $CVSPATH/docbook/*.png $WWWPATH/docbook
cp $CVSPATH/docbook/*.html $WWWPATH/docbook
cp -R $CVSPATH/docbook/screens/* $WWWPATH/docbook/screens/
cp -R $CVSPATH/docbook/icons/* $WWWPATH/docbook/icons/
cp -R $CVSPATH/docbook/networkdiagrams/* $WWWPATH/docbook/networkdiagrams/
mv /docbook/* $WWWPATH/docbook
