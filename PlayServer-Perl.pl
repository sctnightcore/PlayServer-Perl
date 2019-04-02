use strict;
use warnings;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use Config::IniFiles;
use JSON;
use AntiCaptcha;
use File;
use PlayServer;
use Data::Dumper;
use Win32::Console::ANSI;
use Win32::Console;
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
		#Get checksun
		my $checksum = $playserver->getimg_saveimg();
		#Get answer
		my $answer = $anticaptcha->get_answer($checksum);
		#push checksum / answer to hashdata
		push (@{$hash_data->{all_data}},{ checksum => $checksum, answer => $answer });
		# remove checksum file
		File::file_remove($hash_data->{all_data}->[0]->{checksum});		
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
			if ($res_playserver->{'success'} eq '1' ) {
				print "[+] | [ \e[0;32mSUCCESS\e[0m ] | [ \e[1;37mCHECKSUM:\e[0m ".$hash_data->{all_data}->[0]->{checksum}." ] | [ \e[1;37mANSWER:\e[0m ".$hash_data->{all_data}->[0]->{answer}." ]\n";
				$success += 1;	
			} else {
				print "[-] | [ \e[0;31mFAIL\e[0m ] | [ \e[1;37mCHECKSUM:\e[0m ".$hash_data->{all_data}->[0]->{checksum}." ] | [ \e[1;37mANSWER:\e[0m ".$hash_data->{all_data}->[0]->{answer}." ]\n";
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
	require Win32::Pipe;
}

1;