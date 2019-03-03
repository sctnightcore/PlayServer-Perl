use strict;
use Config::IniFiles;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use Win32::Console;

use AntiCaptcha;
use File;
use PlayServer;
use Var qw(@count @success @fail);
my $cfg = Config::IniFiles->new( -file => "config.ini" );
my $server = $cfg->val('Setting','URL');
my $serverid = $cfg->val('Setting','SERVERID');
my $gameid = $cfg->val( 'Setting', 'GAMEID' );
my $antikey = $cfg->val('Setting','AntiCaptchakey');
my $CONSOLE = new Win32::Console();

main();
sub main {
	loadlib();
	system $^O eq 'MSWin32' ? 'cls' : 'clear';
	print "================================\n";
	print "PlayServer-Perl\n";
	print "By sctnightcore\n";
	print "================================\n";
	my $nextruntime=0;
	$CONSOLE->Title("[Count]: 0 | [Success]: 0 | [Fail]: 0 | BY sctnightcore");
	while () {
		my $checksum = PlayServer::getimg_saveimg($server); #get img 
		sleep 0.5;
		my ($ans,$b) = AntiCaptcha::anti_captcha($checksum,$antikey); # get ans
		File::file_remove($checksum);
		if(time() >= $nextruntime) {
				PlayServer::send_answer($ans,$checksum,$server,$gameid,$serverid,$b);
				$nextruntime = time()+61;
		}
		my $sizecount = scalar(@count);
		my $sizesuccess = scalar(@success);
		my $sizefail = scalar(@fail);
		$CONSOLE->Title("[Count]: ".$sizecount." | [Success]: ".$sizesuccess." | [Fail]: ".$sizefail." | By sctnightcore");
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
	require Win32::Console::ANSI;
	require Win32::Console;
}