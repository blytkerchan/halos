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
	cat > bootstrap.pl <<EOF
#! /usr/bin/perl -w
while (<>)
{
	\$_ =~ s/\\\$\\\$__PACKAGE__\\\$\\\$/$PACKAGE/g;
	\$_ =~ s/\\\$\\\$__VERSION__\\\$\\\$/$VERSION/g;
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
	if [ -d cpu-info ]; then
		PROGRAMS="cpu-info $PROGRAMS"
	fi
	if [ -d cpu ]; then
		MODULES="cpu $MODULES"
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

	print \$_;
}
EOF
	cat Makefile.in.in | perl bootstrap.pl > Makefile.in
}

function gen_link_mk()
{
	rm -f link.mk
	cat >link.mk <<EOF
cpu-info : \$(OBJ)
	\$(CC) \$(LDFLAGS) -o \$@ \$^
EOF
}

get_version_info
gen_configure_ac
gen_makefile_in
gen_link_mk

aclocal && \
autoconf