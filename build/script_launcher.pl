#!/usr/bin/env perl
# Win32 Perl script launcher
# This file is meant to be compiled by PerlApp. It acts like a mini-Perl interpreter.
#
# Your script's initialization and main loop code should be placed in a function
# called __start() in the main package. That function will be called by this
# launcher. The reason for this is that otherwise, the perl interpreter will be
# in "eval" all the time while running your script. It will break __DIE__ signal
# handlers that check for the value of $^S.
#
# If your script is run by this launcher, the environment variable INTERPRETER is
# set. Your script should call __start() manually if this environment variable is not
# set.
#
# Example script:
# our $quit = 0;
#
# sub __start {
#	print "Hello world initialized.\n";
#	while (!$quit) {
#		...
#	}
# }
#
# __start() unless defined $ENV{INTERPRETER};
use strict;

# PerlApp 6's @INC doesn't contain '.', so add it
my $hasCurrentDir;
foreach (@INC) {
	if ($_ eq ".") {
		$hasCurrentDir = 1;
		last;
	}
}

push @INC, "." if (!$hasCurrentDir);

if (0) {
	# Force PerlApp to include the following modules
	require lib;
	require strict;
	require warnings;
	require Config::IniFiles;
	require HTTP::Tiny;
	require JSON::XS;
	require POSIX;
	require WWW::Mechanize;
	require WebService::Antigate;
	require Term::ANSIColor;
	require Win32::Console::ANSI;
	require Win32::Console;
	require URI::Encode;
	require FindBin;
	require Data::Dumper;
}

$0 = PerlApp::exe() if ($PerlApp::TOOL eq "PerlApp");
if ($0 =~ /\.exe$/i) {
	$ENV{INTERPRETER} = $0;
}

my $file = 'PlayServer-Perl.pl';

if ($ARGV[0] eq '!') {
	shift;
	while (@ARGV) {
		if ($ARGV[0] =~ /^-I(.*)/) {
			unshift @INC, $1;
		} else {
			last;
		}
		shift;
	}
	$file = shift;
}

$0 = $file;
do $file;
if ($@) {
	print $@;
	print "\nPress ENTER to exit.\n";
	<STDIN>;
	exit 1;
} else {
	main::__start() if defined(&main::__start);
}
