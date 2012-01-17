#
# usage:
#       under the porting workspace, run:
#       $. /path/to/envsetup.sh [android_build_top] [android_product_out]
#
# description:
#       If android build environment has been setup (i.e. lunch'ed), the value of
#       android_build_top and android_product_out specified here would not be used.
#       If android_build_top or android_product_out is empty, then ?

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
   fi
fi

if [ -n "$PORT_ROOT" ]; then
    PORT_BUILD=$PORT_ROOT/build
    ANDROID_TOP=${ANDROID_BUILD_TOP:=$1}
    ANDROID_OUT=${ANDROID_PRODUCT_OUT:=$2}
    export PORT_ROOT PORT_BUILD ANDROID_TOP ANDROID_OUT
    echo "PORT_ROOT   = $PORT_ROOT"
    echo "ANDROID_TOP = $ANDROID_TOP"
    echo "ANDROID_OUT = $ANDROID_OUT"
fi
