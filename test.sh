#
# This script is meant to be run within a container, it will add and
# remove packages.
#

set -e
set -x

#DEBPKG=d/aspell-de_20161207-7_all.deb
#DEB=aspell-de
#PKG=aspell6-de-20161207-7-0
#LANG=de
#DICTS="de de_AT de_CH de_DE"

#DEBPKG=d/aspell-de-1901_2-35_all.deb
#DEB=aspell-de-1901
#PKG=aspell6-de-1901-2-35-0
#LANG=de-1901
#DICTS="de-1901 de_CH-1901 de_DE-1901"

. ./testinfo

sudo apt-get -y purge $DEB

tar xfv $PKG.tar.bz2
cd $PKG
./configure
make
for d in $DICTS
do
    aspell -d ./$d dump master > $d.lst
    aspell -l ./$LANG expand < $d.lst > $d.exp
    #cat $d.exp | aspell -a -d ./$d > $d.check
    lcat $d.check | fgrep -v '*' | fgrep -v '+' | awk NF 
done

cd ..

sudo dpkg -i $DEBPKG
for d in $DICTS
do
    aspell -d $d dump master > $d.lst
    aspell -l $LANG expand < $d.lst > $d.exp
    diff -u $PKG/$d.exp $d.exp
done

sudo apt-get -y purge $DEB

#rm -r $PKG
