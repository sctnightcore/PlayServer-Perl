package Utils;
use strict;
use warnings;
use WWW::Mechanize;
use Data::Dumper;
use URI::Encode qw(uri_encode uri_decode);
use Var;

sub title_count {
	my $success = defined($success_count) ? $success_count : 0;
	my $fail = defined($fail_count) ? $fail_count : 0;
	my $report = defined($report_count) ? $report_count : 0;
	my $report_success = defined($report_count_success) ? $report_count_success : 0;
	my $report_fail = defined($report_count_fail) ? $report_count_fail : 0;
    $interface->title("[ GameID: $gameid | ServerID: $serverid ]-[ Success: $success | Fail: $fail ]");
}

sub get_Url {
	my ($serverid) = @_;
	my $mech = WWW::Mechanize->new();
	my $k;
	$mech->get( 'https://playserver.in.th/index.php/Server/'.$serverid);
	my @links = $mech->find_all_links(url_regex => qr/prokud\.*/);
	for my $link ( @links ) {
		$k = $link->url;
	}
	my @result = split '/', $k;
	return uri_encode($result[6]);
}

1;