#! /bin/sh
case "$1" in
	-c)
		CC=gcc
		shift 1
	;;
	-c++)
		CC=g++
		shift 1
	;;
	*)
		CC=gcc
	;;
esac
DIR="$1"
shift 1
case "$DIR" in 
"" | ".")
	$CC -MM -MG "$@" | sed -e 's@^\(.*\)\.o:@\1.d \1.o:@'
	;;
*)
	$CC -MM -MG "$@" | sed -e "s@^\(.*\)\.o:@$DIR/\1.d $DIR/\1.o:@"
	;;
esac

