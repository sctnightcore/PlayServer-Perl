package File;
use strict;
use warnings;

sub file_remove {
	my ($checksum) = @_;
	my $file = "img/$checksum.png";
	my $removed = unlink($file);
}

sub clear_oldchecksum {
	unlink glob "img/*.png";
}
1;