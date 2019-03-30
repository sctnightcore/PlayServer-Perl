use strict;
use warnings;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use Config::IniFiles;
use JSON;
use AntiCaptcha;
use File;
use PlayServer;
use Win32::Console::ANSI;
my $cfg = Config::IniFiles->new( -file => "config.ini" );
my $c = Win32::Console->new();
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

#start ! 
Start();
sub Start {
	Loadlib();
	my $startsendagain = 0;
	my $success = 0;
	my $fail = 0;
	my $waitsend = 0;
	my $count_savedata = 0;
	my $hash_data = {};
	print "================================\n";
	print "PlayServer-Perl\n";
	print "by sctnightcore\n";
	print "github.com/sctnightcore\n";
	print "================================\n";
	$c->Title('[ Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.'] BY SCTNIGHTCORE');
	my $playserver = PlayServer->new( Server_Url => $cfg->val('Setting','URL'), GameID => $cfg->val( 'Setting', 'GAMEID' ), ServerID => $cfg->val('Setting','SERVERID'));
	my $anticaptcha = AntiCaptcha->new( anticaptcha_key => $cfg->val('Setting','AntiCaptchakey'));
	while () {
		$count_savedata++;
		my $checksum = $playserver->getimg_saveimg();
		my $answer = $anticaptcha->get_answer($checksum);
		$hash_data->{all_data}->[$count_savedata]->{checksum} = $checksum;
		$hash_data->{all_data}->[$count_savedata]->{answer} = $answer;
		$waitsend += 1;
		$c->Title('[ Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.'] BY SCTNIGHTCORE');
		if (time() >= $startsendagain) {
			$waitsend -= 1;
			my $sendchecksum = $hash_data->{all_data}->[0]->{checksum};
			my $sendanswer = $hash_data->{all_data}->[0]->{answer};
			my $sleeptime = $playserver->send_answer($sendanswer, $sendchecksum);
			if ($send_answer->{'success'} eq '1') {
				printf("[+][%02d:%02d:%02d] | \e[0;32m%5s\e[0m | %5s | %5s ", $hour, $min, $sec,'SUCCESS',"$sendchecksum.png","$sendanswer");
				$success += 1;
			} else {
				printf("[-][%02d:%02d:%02d] | \e[0;32m%5s\e[0m | %5s | %5s ", $hour, $min, $sec,'FAIL',"$sendchecksum.png","$sendanswer");
				$fail += 1;
			}
			shift @{$hash_data->{all_data}}; #next checksum / answer
			$startsendagain = time() + $sleeptime->{'wait'} + 1;
			$c->Title('[ Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.'] BY SCTNIGHTCORE');
		}
		File::file_remove($checksum);
		sleep 10; 
	}
}


sub Loadlib {
	require Config::IniFiles;
	require LWP::UserAgent;
	require JSON;
	require AntiCaptcha;
	require File;
	require PlayServer;
	require WebService::Antigate;
	require Term::ANSIColor;
	require Win32::Console::ANSI;
	require Win32::Console;
}

1;