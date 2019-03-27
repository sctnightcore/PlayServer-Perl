package Main;
use strict;
use Config::IniFiles;
use JSON;
use AntiCaptcha;
use File;
use PlayServer;
use Win32::Console;
sub Start {
	my $startsendagain = 0;
	my $success = 0;
	my $fail = 0;
	my $waitsend = 0;
	my $c = Win32::Console->new();
	print "================================\n";
	print "PlayServer-Perl\n";
	print "by sctnightcore\n";
	print "github.com/sctnightcore\n";
	print "================================\n";
	$c->Title('[PlayServer-Perl] => [Success:'.$success.'|Fail: '.$fail.'|WaitSend:'.$waitsend.']');
	my $cfg = Config::IniFiles->new( -file => "config.ini" );
	my $server = $cfg->val('Setting','URL');
	my $serverid = $cfg->val('Setting','SERVERID');
	my $gameid = $cfg->val( 'Setting', 'GAMEID' );
	my $antikey = $cfg->val('Setting','AntiCaptchakey');
	while () {
		my $b = AntiCaptcha::checkmoney($antikey);
		my $checksum = PlayServer::getimg_saveimg($server); #get img
		my $answer = AntiCaptcha::anti_captcha($checksum,$antikey); # get ans
		File::file_remove($checksum);
		chomp($b,$checksum,$answer);
		$waitsend += 1;
		if (time() >= $startsendagain) {
			my $send_answer = PlayServer::send_answer($answer,$checksum,$server,$gameid,$serverid,$b);
			$waitsend -= 1;
			if ($send_answer->{'success'} eq '1') {
				print("[B:$b] | \e[0;32m[Success]\e[0m | $checksum.png | $answer\n");
				$success += 1;
			} else {
				print("[B:$b] | \e[0;31m[Fail]\e[0m | $checksum.png | $answer\n");
				$fail += 1;
			}
			#$startsendagain = time() + $send_answer->{'wait'} + 1;
			$startsendagain = time() + 1;
			$c->Title('[PlayServer-Perl] => [Success:'.$success.'|Fail: '.$fail.'|WaitSend:'.$waitsend.']');
		}
		sleep 10;
		$c->Title('[PlayServer-Perl] => [Success:'.$success.'|Fail: '.$fail.'|WaitSend:'.$waitsend.']');
	}
}

sub Loadlib {
	require Config::IniFiles;
	require HTTP::Tiny;
	require JSON;
	require AntiCaptcha;
	require File;
	require PlayServer;
	require Main;
	require WebService::Antigate;
	require Term::ANSIColor;
	require Win32::Console::ANSI;
	require Win32::Console;
}

1;