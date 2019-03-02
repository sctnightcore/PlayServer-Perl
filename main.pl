use strict;
use threads;
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
	print "================================\n";
	print "PlayServer-Perl\n";
	print "By sctnightcore\n";
	print "================================\n";
	while () {
		my $checksum = PlayServer::getimg_saveimg($server); #get img 
		sleep 3;
		my ($ans,$b) = AntiCaptcha::anti_captcha($checksum,$antikey); # get ans 
		PlayServer::send_answer($ans,$checksum,$server,$gameid,$serverid,$b); #send ans
		File::file_remove($checksum);
		print "Wait 61 sec\n";
		sleep 61;
	}
}