package File;
use strict;
use warnings;

sub file_remove {
	my ($checksum) = @_;
	my $file = "img/$checksum.png";
	my $removed = unlink($file);
}

sub clear_oldcheckfile {
	unlink glob "img/*.png";
	print "\e[1;42;1mDone\e[0m\n";
}
1;