#!/bin/bash

FILES=`curl -H 'Accept: application/vnd.github.v3+json' https://api.github.com/repos/radiorabe/kickstart/contents | awk '/name/ {print $2}' | sed 's/[",]//g'`
echo $FILES

cat tpl/menu.pre.cfg > ipxe.menu
cat /dev/null > ipxe.items
for FILE in $FILES; do
    NAME="${FILE%.*}"
    if [ "$NAME" != "README" ]; then
        URL="https://raw.githubusercontent.com/radiorabe/kickstart/develop/${FILE}"
        cat tpl/item.cfg | sed -e "s/<file>/$FILE/g" -e "s/<name>/$NAME/g" -e "s@<url>@$URL@g" >> ipxe.menu
        MENU=`printf "$MENU\nitem $NAME Kickstart $NAME\n"`
        echo "item $NAME Kickstart $NAME" >> ipxe.items
    fi
done
cat tpl/item.post.cfg >> ipxe.menu
cat ipxe.items >> ipxe.menu
rm ipxe.items
cat tpl/menu.post.cfg >> ipxe.menu
