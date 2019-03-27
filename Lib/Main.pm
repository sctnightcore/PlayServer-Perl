package Main;
use strict;
use Config::IniFiles;
use JSON;
use AntiCaptcha;
use File;
use PlayServer;
use Term::Title 'set_titlebar', 'set_tab_title';

sub Start {
	my $startsendagain = 0;
	my $success = 0;
	my $fail = 0;
	my $waitsend = 0;
	print "================================\n";
	print "PlayServer-Perl\n";
	print "by sctnightcore\n";
	print "github.com/sctnightcore\n";
	print "================================\n";
	set_titlebar("[Success]: 0 | [Fail]: 0 | [WaitSend]: 0 | BY sctnightcore");
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
		$waitsend += 1;
		set_titlebar("[Success]: ".$success." | [Fail]: ".$fail." | [WaitSend]: ".$waitsend." | BY sctnightcore");
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
			$startsendagain = time() + $send_answer->{'wait'} + 1;
		}
		set_titlebar("[Success]: ".$success." | [Fail]: ".$fail." | [WaitSend]: ".$waitsend." | BY sctnightcore");
		sleep 10;
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
	require Term::Title;
	require Term::ANSIColor;
	require Win32::Console::ANSI;
}

1;