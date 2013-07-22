#!/bin/bash
#
# usage:
#       under the porting workspace, run:
#       $. /path/to/envsetup.sh [android_build_top] [android_product_out]
#
# description:
#       If android build environment has been setup (i.e. lunch'ed), the value of
#       android_build_top and android_product_out specified here would not be used.
#       If android_build_top or android_product_out is empty, then ?

set -- `getopt "a:t:l:b:h:p:" "$@"`
android_top=
android_lunch=
android_out=
android_product=
ANDROID_BRANCH=
PORT_PRODUCT="Unknown"
help=
while :
do
case "$1" in
    -a) shift; android_top="$1" ;;
	-i) shift; android_product="$1" ;;
    -l) shift; android_lunch="$1";;
    -b) shift; ANDROID_BRANCH="$1";;
    -p) shift; PORT_PRODUCT="$1";;
    -h) help=1;;
    --) break ;;
esac
shift
done
shift

if [ -n "$help" ]; then
    echo "Usage: . /path/to/envsetup [-a android-top [-t android-product] [-l lunch-option] [-b android-branch]]"
    return
fi

if [ -n "$android_top" ]; then
    if [ ! -d "$android_top" ]; then
         echo "Failed: $android_top does not exist"
         return
    fi
    ANDROID_BUILD_TOP=
    ANDROID_PRODUCT_OUT=
    if [ ! -n "$android_product" ]; then
        PORT_ROOT=$PWD
        cd $android_top
        . build/envsetup.sh
        lunch $android_lunch
        cd $PORT_ROOT
    else
        android_top=${android_top%/}
        android_out=$android_top/out/target/product/$android_product
    fi
    USE_ANDROID_OUT=true
    export USE_ANDROID_OUT
else
    ANDROID_BRANCH=
fi

TOPFILE=build/porting.mk
if [ -f $TOPFILE ] ; then
   PORT_ROOT=$PWD
else
   while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
       cd .. > /dev/null
   done
   if [ -f $PWD/$TOPFILE ]; then
       PORT_ROOT=$PWD
   else
       echo "Failed! run me under you porting workspace"
       return
   fi
fi
export PATH=$PORT_ROOT/tools:$PATH

if [ -n "$PORT_ROOT" ]; then
    PORT_BUILD=$PORT_ROOT/build
    ANDROID_TOP=${ANDROID_BUILD_TOP:=$android_top}
    ANDROID_OUT=${ANDROID_PRODUCT_OUT:=$android_out}
    export PORT_ROOT PORT_BUILD ANDROID_TOP ANDROID_OUT ANDROID_BRANCH PORT_PRODUCT
    echo "PORT_ROOT       = $PORT_ROOT"
    echo "ANDROID_TOP     = $ANDROID_TOP"
    echo "ANDROID_OUT     = $ANDROID_OUT"
    echo "PORT_PRODUCT    = $PORT_PRODUCT"
    echo "USE_ANDROID_OUT = $USE_ANDROID_OUT"
    echo "ANDROID_BRANCH  = $ANDROID_BRANCH"
fi
