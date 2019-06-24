use strict;
use WWW::Mechanize;
use Dir::Self;
use Config::IniFiles;
use Data::Dumper;
use URI::Encode qw(uri_encode uri_decode);
use lib __DIR__ . "/src";
use Core_Logic;

sub __start {
	if ($^O eq 'MSWin32' ) {
		my $config = Config::IniFiles->new( -file => __DIR__."/Config/config.ini" ) or die "Failed to create Config::IniFiles object\n";
		my $serverid = $config->val('Setting', 'SERVERID');
		my $antikey = $config->val('Setting', 'AntiCaptchakey');
		my $gameid = $config->val('Setting', 'GAMEID');
		my $debug = $config->val('Setting', 'DEBUG');
		my $url = get_Url($serverid);
		my $core = Core_Logic->new( 
			Path => __DIR__ , 
			Anticaptcha_key => $antikey, 
			GameID => $gameid, 
			ServerUrl => $url, 
			ServerID => $serverid,
			Debug => $debug
		);
		$core->MainLoop();
	} else {
		print("PlayServer-Perl work only Windown\n");
		print("Press ENTER to exit.\n");
		<STDIN>;
		exit;
	}

}
__start() unless defined $ENV{INTERPRETER};


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