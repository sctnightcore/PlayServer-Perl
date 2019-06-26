use strict;
use Dir::Self;
use lib __DIR__ . "/src";
use Core_Logic;

sub __start {
	if ($^O eq 'MSWin32' ) {
		my $core = Core_Logic->new( Path => __DIR__ );
		$core->MainLoop();
	} else {
		print("PlayServer-Perl work only Windown\n");
		print("Press ENTER to exit.\n");
		<STDIN>;
		exit;
	}

}
__start() unless defined $ENV{INTERPRETER};


