use strict;
use Config::IniFiles;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";

use AntiCaptcha;
use File;
use PlayServer;
my $cfg = Config::IniFiles->new( -file => "config.ini" );
my $server = $cfg->val('Setting','URL');
my $serverid = $cfg->val('Setting','SERVERID');
my $gameid = $cfg->val( 'Setting', 'GAMEID' );
my $antikey = $cfg->val('Setting','AntiCaptchakey');

main();
sub main {
	loadlib();
	print "================================\n";
	print "PlayServer-Perl\n";
	print "By sctnightcore\n";
	print "================================\n";
	my $nextruntime=0;
	while () {
		my $checksum = PlayServer::getimg_saveimg($server); #get img 
		my ($ans,$b) = AntiCaptcha::anti_captcha($checksum,$antikey); # get ans
		File::file_remove($checksum);
		if(time() >= $nextruntime){
				PlayServer::send_answer($ans,$checksum,$server,$gameid,$serverid,$b);
				$nextruntime = time()+61;
		}
	}
}

sub loadlib {
	require Config::IniFiles;
	require HTTP::Tiny;
	require JSON;
	require AntiCaptcha;
	require File;
	require PlayServer;
	require WebService::Antigate::V2;
}