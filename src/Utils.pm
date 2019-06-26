package Utils;
use strict;
use warnings;
use WWW::Mechanize;
use Data::Dumper;
use URI::Encode qw(uri_encode uri_decode);
use Config::IniFiles;
use AntiCaptcha::Func_ac;
use PlayServer::Func_ps;
use Interface::Console;
use Var;

sub title_count {
	my $success = defined($success_count) ? $success_count : 0;
	my $fail = defined($fail_count) ? $fail_count : 0;
	my $report = defined($report_count) ? $report_count : 0;
	my $report_success = defined($report_count_success) ? $report_count_success : 0;
	my $report_fail = defined($report_count_fail) ? $report_count_fail : 0;
    $interface->title("[ GameID: $gameid | ServerID: $serverid ]-[ Success: $success | Fail: $fail ]");
}


sub Logic_Start {
	$config = Config::IniFiles->new( -file => $path."/Config/config.ini" ) or die "Failed to create Config::IniFiles object\n";
	$serverid = $config->val('Setting', 'SERVERID');
	$gameid = $config->val('Setting', 'GAMEID');
	$interface = Interface::Console->new();
	$interface->title("PlayServer Perl Vote by sctnightcore");
	$interface->writeoutput("===============================\n",'white');
	$interface->writeoutput("PlayServer Vote by sctnightcore\n",'white');
	$interface->writeoutput("github.com/sctnightcore\n",'white');
	$interface->writeoutput("===============================\n",'white');
	$serverurl = get_Url($config->val('Setting', 'SERVERID'));
	$func_ac = AntiCaptcha::Func_ac->new( AntiKey => $config->val('Setting', 'AntiCaptchakey'), Debug => 0);
	$func_ps = PlayServer::Func_ps->new( ServerUrl => $serverurl, ServerID => $serverid, GameID => $gameid, Debug => 0);
	title_count();
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