package File;
use strict;
use warnings;

sub file_remove {
	my ($checksum) = @_;
	my $file = "img/$checksum.png";
	my $removed = unlink($file);
}

1;