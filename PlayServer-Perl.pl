use strict;
use Config::IniFiles;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use JSON;
use AntiCaptcha;
use File;
use PlayServer;
use Var qw(@success @fail);
use Term::Title 'set_titlebar', 'set_tab_title';
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
	my $startsendagain = 0;
	my $count_checksum_answer = 0;
	set_titlebar("[Success]: ".scalar(@success)." | [Fail]: ".scalar(@fail)." | BY sctnightcore");
	while () {
		my $b = AntiCaptcha::checkmoney($antikey);
		my $checksum = PlayServer::getimg_saveimg($server); #get img 
		my $answer = AntiCaptcha::anti_captcha($checksum,$antikey); # get ans
		File::file_remove($checksum);
		if ( time >= $startsendagain ) {
			$count_checksum_answer++;
			my $delaytime = PlayServer::send_answer($answer,$checksum,$server,$gameid,$serverid,$b);
			$startsendagain = $delaytime + 1;
			set_titlebar("[Success]: ".scalar(@success)." | [Fail]: ".scalar(@fail)." | BY sctnightcore");
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
	require Var;
	require WebService::Antigate;
	require Term::Title;
	require Term::ANSIColor;
	require Win32::Console::ANSI;

}


