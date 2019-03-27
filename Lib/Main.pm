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
	my $count_savedata = 0;
	my $count_senddata = 0;
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
	my $hash_data;
	while () {
		$count_savedata++;
		my $b = AntiCaptcha::checkmoney($antikey);
		my $checksum = PlayServer::getimg_saveimg($server); #get img
		my $answer = AntiCaptcha::anti_captcha($checksum,$antikey); # get ans
		File::file_remove($checksum);
		$hash_data->{all_data}->[$count_savedata]->{checksum} = $checksum;
		$hash_data->{all_data}->[$count_savedata]->{answer} = $answer;
		$waitsend += 1;
		$c->Title('[PlayServer-Perl] => [Success:'.$success.'|Fail: '.$fail.'|WaitSend:'.$waitsend.']');
		if (time() >= $startsendagain) {
			$count_senddata++;
			my $send_answer = PlayServer::send_answer($hash_data->{all_data}->[$count_senddata]->{answer},$hash_data->{all_data}->[$count_senddata]->{checksum},$server,$gameid,$serverid,$b);
			$waitsend -= 1;
			if ($send_answer->{'success'} eq '1') {
				print("[+] | \e[0;32m[Success]\e[0m | $checksum.png | $answer\n");
				$success += 1;
			} else {
				print("[-] | \e[0;31m[Fail]\e[0m | $checksum.png | $answer\n");
				$fail += 1;
			}
			shift @{$hash_data->{all_data}};
			$startsendagain = time() + $send_answer->{'wait'} + 1;
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