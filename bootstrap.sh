#! /bin/bash -x
function get_version_info()
{
	export PACKAGE=$(basename $(dirname $0))
	if [ "$PACKAGE" = "." ]; then
		PACKAGE=$(basename $(pwd))
	fi
	if [ ! -d $PACKAGE ]; then
		PACKAGE=$(echo $PACKAGE | sed s/^[^-]*-//g)
	fi
	echo PACKAGE=$PACKAGE
	if [ ! -d $PACKAGE ]; then
		echo "The $PACKAGE directory does not exist!"
		echo "Bailing out"
		(exit 1); exit 1;
	fi
	if [ ! -f $PACKAGE/version ]; then
		echo "The $PACKAGE/version file does not exist or is not a regular file!"
		echo "Bailing out"
		(exit 1); exit 1;
	fi
	export VERSION=$(cat $PACKAGE/version)
	echo VERSION=$VERSION
}

function gen_configure_ac()
{
	BUILD_KERNEL=0

	if [ x"$PACKAGE" = xkernel ]; then
		BUILD_KERNEL=1
	fi
	cat > bootstrap.pl <<EOF
#! /usr/bin/perl -w
while (<>)
{
	\$_ =~ s/\\\$\\\$__PACKAGE__\\\$\\\$/$PACKAGE/g;
	\$_ =~ s/\\\$\\\$__VERSION__\\\$\\\$/$VERSION/g;
	\$_ =~ s/\\\$\\\$__BUILD_KERNEL__\\\$\\\$/$BUILD_KERNEL/g;
	print \$_;
}
EOF
	cat configure.ac.in | perl bootstrap.pl > configure.ac
}

function gen_makefile_in()
{
	PROGAMS=
	LIBRARIES=
	MODULES=
	KERNEL=

	# programs go here
	if [ -d cpu-info ]; then
		PROGRAMS="cpu-info $PROGRAMS"
	fi

	# modules go here
	if [ -d bochs ]; then
		MODULES="bochs $MODULES"
	fi
	if [ -d cpu ]; then
		MODULES="cpu $MODULES"
	fi
	if [ -d bootstrap ]; then
		MODULES="bootstrap $MODULES"
	fi
	if [ -d event ]; then
		MODULES="event $MODULES"
	fi
	if [ -d mm ]; then
		MODULES="mm $MODULES"
	fi
	if [ -d klib ]; then
		MODULES="klib $MODULES"
	fi
	if [ -d sched ]; then
		MODULES="sched $MODULES"
	fi
	if [ -d drivers ]; then
		MODULES="drivers $MODULES"
	fi
	
	# libraries go here
	if [ -d elf ]; then
		MODULES="elf $MODULES"
	fi

	# the kernel goes here
	if [ -d kernel ]; then
		KERNEL="halos"
		MODULES="kernel $MODULES"
	fi

	cat > bootstrap.pl <<EOF
#! /use/bin/perl -w
while (<>)
{
	\$_ =~ s/\\\$\\\$__PACKAGE__\\\$\\\$/$PACKAGE/g;
	\$_ =~ s/\\\$\\\$__VERSION__\\\$\\\$/$VERSION/g;
	\$_ =~ s/\\\$\\\$__LIBRARIES__\\\$\\\$/$LIBRARIES/g;
	\$_ =~ s/\\\$\\\$__PROGRAMS__\\\$\\\$/$PROGRAMS/g;
	\$_ =~ s/\\\$\\\$__MODULES__\\\$\\\$/$MODULES/g;
	\$_ =~ s/\\\$\\\$__KERNEL__\\\$\\\$/$KERNEL/g;
	
	print \$_;
}
EOF
	cat Makefile.in.in | perl bootstrap.pl > Makefile.in
}

function gen_link_mk()
{
	rm -f link.mk
	cat >link.mk <<EOF
cpu-info.exe : \$(OBJ)
	\$(CC) \$(LDFLAGS) -o \$@ \$^

halos : \$(OBJ)
	\$(LD) \$(LDFLAGS) -T\$(srcdir)/config/kernel.lds -o\$@ \$^
	nm -C \$@ | cut -d ' ' -f 1,3 > halos.map
	size \$@

EOF
}

get_version_info
gen_configure_ac
gen_makefile_in
gen_link_mk

aclocal && \
autoconf
