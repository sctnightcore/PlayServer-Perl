use Dir::Self;
use strict;
use lib __DIR__ . "/src";
use Core;

sub __start {
	print "\t===============================\n";
	print "\tPlayServer Vote by sctnightcore\n";
	print "\tgithub.com/sctnightcore\n";
	print "\t===============================\n";
	Core::Core_Logic(__DIR__);
}
__start() unless defined $ENV{INTERPRETER};