use strict;
use warnings;
use Config::IniFiles;
use JSON;
use Data::Dumper;
use Win32::Console::ANSI;
use Win32::Console;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use AntiCaptcha;
use File;
use PlayServer;
my $cfg = Config::IniFiles->new( -file => "config.ini" );
my $c = Win32::Console->new();
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
#start ! 
Start();

sub Start {
	Load_lib();
	print "================================\n";
	print "PlayServer-Perl\n";
	print "by sctnightcore\n";
	print "github.com/sctnightcore\n";
	print "================================\n";	
	my $playserver = PlayServer->new( Server_Url => $cfg->val('Setting','URL'), GameID => $cfg->val( 'Setting', 'GAMEID' ), ServerID => $cfg->val('Setting','SERVERID'));
	my $anticaptcha = AntiCaptcha->new( anticaptcha_key => $cfg->val('Setting','AntiCaptchakey'));
	my $startsendagain = 0;
	my $success = 0;
	my $fail = 0;
	my $waitsend = 0;
	my $hash_data;
	$anticaptcha->checkbalance();
	$c->Title('[ Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.' ] BY SCTNIGHTCORE');
	while () {
		#Get checksun
		my $checksum = $playserver->getimg_saveimg();
		#Get answer
		my $answer = $anticaptcha->get_answer($checksum);
		#push checksum / answer to hashdata
		push (@{$hash_data->{all_data}},{ checksum => $checksum, answer => $answer });
		# remove checksum file
		File::file_remove($checksum);		
		#update var
		$waitsend += 1;
		#update process title
		$c->Title('[ Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.' ] BY SCTNIGHTCORE');
		#send Answer evey 61 sec
		if (time() >= $startsendagain) {
			#update var
			$waitsend -= 1;
			#send answer
			my $res_playserver = $playserver->send_answer($hash_data->{all_data}->[0]->{answer}, $hash_data->{all_data}->[0]->{checksum});
			#check res playserver
			#0 = Fail / 1 = Success
			if ($res_playserver->{'success'}) {
				printf("[\e[1;37m%02d:%02d:%02d\e[0m] | [\e[1;42;1mSUCCESS\e[0m] | [\e[1;37mCHECKSUM:\e[0m %s.png] | [\e[1;37mANSWER:\e[0m %s]\n", $hour, $min, $sec,$hash_data->{all_data}->[0]->{checksum},$hash_data->{all_data}->[0]->{answer});
				$success += 1;	
			} else {
				printf("[\e[1;37m%02d:%02d:%02d\e[0m] | [\e[1;41;1mFail\e[0m] | [\e[1;37mCHECKSUM:\e[0m %s.png] | [\e[1;37mANSWER:\e[0m %s]\n", $hour, $min, $sec,$hash_data->{all_data}->[0]->{checksum},$hash_data->{all_data}->[0]->{answer});
				$fail += 1;			
			}
			#next checksum / answer for send next time
			shift @{$hash_data->{all_data}}; 
			#update var time for send again 
			$startsendagain = time() + $res_playserver->{'wait'} + 1;
			#update process title
			$c->Title('[ Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.' ] BY SCTNIGHTCORE');
		}
		#sleep 15 sec for back to loop
		sleep 15; 
	}
}

sub Load_lib {
	require Config::IniFiles;
	require HTTP::Tiny;
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