package ProxyMode;
use strict;
use warnings;

sub Load_Proxytxt {
	my $filename = 'proxy.txt';
	open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
	while (my $row = <$fh>) {
		chomp $row;
		$proxy_data->{proxy_data}->{$row}->{used} = 0;
	}
}

sub updateproxydata_used {
	my ($proxy) = @_;
	$proxy_data->{proxy_data}->{$proxy}->{used} = 1;
}

sub resetproxydata_used {
	my ($proxy) = @_;
	$proxy_data->{proxy_data}->{$proxy}->{used} = 0;
}

1;
