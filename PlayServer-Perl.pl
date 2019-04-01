use strict;
use warnings;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use Config::IniFiles;
use JSON;
use AntiCaptcha;
use File;
use PlayServer;
use pipe;
use Win32::Console::ANSI;
use Switch;

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
	my $hash_data;
	print "================================\n";
	print "PlayServer-Perl\n";
	print "by sctnightcore\n";
	print "github.com/sctnightcore\n";
	print "================================\n";
	$c->Title('[ Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.' ] BY SCTNIGHTCORE');
	my $playserver = PlayServer->new( Server_Url => $cfg->val('Setting','URL'), GameID => $cfg->val( 'Setting', 'GAMEID' ), ServerID => $cfg->val('Setting','SERVERID'));
	my $anticaptcha = AntiCaptcha->new( anticaptcha_key => $cfg->val('Setting','AntiCaptchakey'));
	while () {
		$count_savedata++;
		#Get checksun
		my $checksum = $playserver->getimg_saveimg();
		#Get answer
		my $answer = $anticaptcha->get_answer($checksum);
		#push checksum / answer to hashdata
		push (@{$hash->{all_data}},{ checksum => $checksum, answer => $answer });
		if ($cfg->val('Setting','DEBUG') eq '1' ) {
			pipe::client($hash->{all_data}->[0]->{'checksum'}, $hash->{all_data}->[0]->{'answer'}, $count_savedata) || die "u need run Log.pl\n";
		}
		#update var
		$waitsend += 1;
		#update process title
		$c->Title('[ Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.' ] BY SCTNIGHTCORE');
		#send Answer evey 61 sec
		if (time() >= $startsendagain) {
			#update var
			$waitsend -= 1;
			
			my $sendchecksum = $hash_data->{all_data}->[0]->{'checksum'};
			my $sendanswer = $hash_data->{all_data}->[0]->{'answer'};
			#send answer
			my $res_playserver = $playserver->send_answer($sendanswer, $sendchecksum);
			#check res playserver
			switch ($res_playserver->{'success'}) {
				case 0 { 
					printf("[-][%02d:%02d:%02d] | \e[0;32m%5s\e[0m | %5s | %5s ", $hour, $min, $sec, 'FAIL', $hash_data->{all_data}->[0]->{'checksum'}.'.png', $hash_data->{all_data}->[0]->{'answer'});
					$fail += 1;
				}
				case 1 { 

					printf("[+][%02d:%02d:%02d] | \e[0;32m%5s\e[0m | %5s | %5s ", $hour, $min, $sec, 'SUCCESS', $hash_data->{all_data}->[0]->{'checksum'}.'.png', $hash_data->{all_data}->[0]->{'answer'}); 
					$success += 1;					
				}
			}
			#next checksum / answer for send next time
			shift @{$hash_data->{all_data}}; 
			#update var time for send again 
			$startsendagain = time() + $res_playserver->{'wait'} + 1;
			#update process title
			$c->Title('[ Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.' ] BY SCTNIGHTCORE');
		}
		# remove checksum file
		File::file_remove($checksum);
		#sleep 20 sec for back to loop
		sleep 20; 
	}
}


sub Loadlib {
	require Config::IniFiles;
	require LWP::UserAgent;
	require JSON;
	require AntiCaptcha;
	require File;
	require PlayServer;
	require pipe;
	require WebService::Antigate;
	require Term::ANSIColor;
	require Win32::Console::ANSI;
	require Win32::Console;
	require Win32::Pipe;
	require Switch;
}

1;