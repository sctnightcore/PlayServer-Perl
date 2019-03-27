use strict;
use Config::IniFiles;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use JSON;
use AntiCaptcha;
use File;
use PlayServer;
use Var qw($success $fail $waitsend);
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
	print "by sctnightcore\n";
	print "github.com/sctnightcore\n";
	print "================================\n";
	set_titlebar("[Success]: ".$success." | [Fail]: ".$fail." | [WaitSend]: ".$waitsend." | BY sctnightcore");
	my $startsendagain = 0;
	while () {
		my $b = AntiCaptcha::checkmoney($antikey);
		my $checksum = PlayServer::getimg_saveimg($server); #get img 
		my $answer = AntiCaptcha::anti_captcha($checksum,$antikey); # get ans
		$waitsend += 1;
		File::file_remove($checksum);
		if( time() >= $startsendagain) {
			my $delaytime = PlayServer::send_answer($answer,$checksum,$server,$gameid,$serverid,$b);
			$waitsend -= 1;
			#$startsendagain = $delaytime + 1;
			$startsendagain = time()+61;
			set_titlebar("[Success]: ".$success." | [Fail]: ".$fail." | [WaitSend]: ".$waitsend." | BY sctnightcore");
		}
		set_titlebar("[Success]: ".$success." | [Fail]: ".$fail." | [WaitSend]: ".$waitsend." | BY sctnightcore");
		sleep 10;
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
