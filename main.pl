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
	my ($success,$fail) = 0;
	while () {
		my ($checksum,$jsonone) = PlayServer::getimg_saveimg($server); #get img 
		my ($ans,$b) = AntiCaptcha::anti_captcha($checksum,$antikey); # get ans 
		my ($success,$fail) = PlayServer::send_answer($ans,$checksum,$server,$gameid,$serverid); #send ans
		if (defined $success) {
			printf("[Money:%s]->[Success:%s] %5s.png %6s %3s\n",$b,$success,$checksum,$ans,$jsonone->{'wait'});
		} else { # $fail
			printf("[Money:%s]->[Fail:%s] %5s.png %6s %3s\n",$b,$fail,$checksum,$ans,$jsonone->{'wait'});
		}
		File::file_remove($checksum);
		sleep 61;
	}	
}