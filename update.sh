#!/bin/bash

FILES=`curl -H 'Accept: application/vnd.github.v3+json' https://api.github.com/repos/radiorabe/kickstart/contents | awk '/name/ {print $2}' | sed 's/[",]//g'`
echo $FILES

cat tpl/menu.pre.cfg > ipxe.menu
for FILE in "$FILES"; do
    NAME="${FILE%.*}"
    URL="https://raw.githubusercontent.com/radiorabe/kickstart/develop/${FILE}"
    cat tpl/item.cfg | sed -e "s/<file>/$FILE/g" -e "s/<name>/$NAME/g" -e "s@<url>@$URL@g" >> ipxe.menu
    MENU=`printf "$MENU\nitem $NAME Kickstart $NAME"`
done
cat tpl/item.post.cfg >> ipxe.menu
echo $MENU >> ipxe.menu
cat tpl/menu.post.cfg >> ipxe.menu
