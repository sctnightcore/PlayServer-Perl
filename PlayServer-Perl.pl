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
	my %checksumhash;
	my %answerhash;
	my $contchecksum_answer = 0;
	my (@checksum_keys, @answer_keys);
	set_titlebar("[Success]: ".scalar(@success)." | [Fail]: ".scalar(@fail)." | [WaitSend]: ".scalar(@checksum_keys)." | BY sctnightcore");
	while () {
		my $b = AntiCaptcha::checkmoney($antikey);
		my $checksum = PlayServer::getimg_saveimg($server); #get img 
		my $answer = AntiCaptcha::anti_captcha($checksum,$antikey); # get ans
		File::file_remove($checksum);
		$checksumhash{'checksum'} = $checksum;
		$answerhash{'answer'} = $answer;
		@checksum_keys = sort keys %checksumhash;
		@answer_keys = sort keys %answerhash;
		if ( time >= $startsendagain ) {
			$contchecksum_answer++;
			my $delaytime = PlayServer::send_answer($answerhash{'answer'}[$contchecksum_answer],$checksumhash{'checksum'}[$contchecksum_answer],$server,$gameid,$serverid,$b);
			$startsendagain = $delaytime + 1;
			delete $checksumhash{shift @checksum_keys};
			delete $answerhash{shift @answer_keys};
			set_titlebar("[Success]: ".scalar(@success)." | [Fail]: ".scalar(@fail)." | [WaitSend]: ".scalar(@checksum_keys)." | BY sctnightcore");
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


