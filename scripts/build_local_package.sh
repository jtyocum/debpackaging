#!/bin/sh

if [ ! -n "$1" ];
then
    echo "Usage: `basename $0` <package>"
    exit 1;
fi

sudo cowbuilder --configfile ~/.pbuilderrc-wheezy --build $(basename "$1")
dupload -t localhost /var/cache/pbuilder/result/$(basename "${1%.dsc}")_amd64.changes
## Uncomment next line to automate removal post build.
#dcmd rm -f $(basename "$FILE")
