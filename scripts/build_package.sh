#!/bin/sh

if [ ! -n "$1" ];
then
    echo "Usage: `basename $0` <release> <package>"
    exit 1;
fi

if [ ! -s Sources_$1 ];
then
    wget http://httpredir.debian.org/debian/dists/$1/main/source/Sources.gz -O - |zcat > Sources_$1
fi

FILE=$(grep-dctrl -X -S "$2" -s Directory,Files < Sources_$1 |awk '/^Directory/ { url = $NF}
/\.dsc$/ { url = url "/" $NF}
END { print url}')

if [ ! -s $(basename "$FILE") ];
then
    dget -d "http://httpredir.debian.org/debian/$FILE"
fi

sudo cowbuilder --configfile ~/.pbuilderrc-wheezy --build $(basename "$FILE")
dupload -t localhost /var/cache/pbuilder/result/$(basename "${FILE%.dsc}")_amd64.changes
## Uncomment next line to automate removal post build.
#dcmd rm -f $(basename "$FILE")
