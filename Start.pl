use strict;
use Config::IniFiles;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use Win32::Console;
use JSON;

use AntiCaptcha;
use File;
use PlayServer;
use Var qw(@success @fail);

my $cfg = Config::IniFiles->new( -file => "config.ini" );
my $server = $cfg->val('Setting','URL');
my $serverid = $cfg->val('Setting','SERVERID');
my $gameid = $cfg->val( 'Setting', 'GAMEID' );
my $antikey = $cfg->val('Setting','AntiCaptchakey');
my $CONSOLE = new Win32::Console();
main();
sub main {
	loadlib();
	hehe($antikey,$gameid,$serverid);
	system $^O eq 'MSWin32' ? 'cls' : 'clear';
	print "================================\n";
	print "PlayServer-Perl\n";
	print "By sctnightcore\n";
	print "================================\n";
	$CONSOLE->Title("[Success]: ".scalar(@success)." | [Fail]: ".scalar(@fail)." | BY sctnightcore");
	while () {
		my $b = AntiCaptcha::checkmoney($antikey);
		if ($b == '0') {
			print "You balance in Anti-Captcha.com is 0 !\n";
			sleep 10;
			exit;
		}
		my $checksum = PlayServer::getimg_saveimg($server); #get img 
		my $ans = AntiCaptcha::anti_captcha($checksum,$antikey); # get ans
		File::file_remove($checksum);
		my $delaytime = PlayServer::send_answer($ans,$checksum,$server,$gameid,$serverid,$b);
		sleep($delaytime);
		print("Sleep $delaytime sec\n");
		$CONSOLE->Title("[Success]: ".scalar(@success)." | [Fail]: ".scalar(@fail)." | BY sctnightcore");
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
	require WebService::Antigate::V2;
	require Win32::Console::ANSI;
	require Win32::Console;
}


