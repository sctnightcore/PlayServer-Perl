use strict;
use warnings;
use Config::IniFiles;
use JSON::XS;
use Data::Dumper;
use Win32::Console::ANSI;
use Win32::Console;
use WWW::Mechanize;
use POSIX;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use AntiCaptcha;
use File;
use PlayServer;
use SocketClient;
my $cfg = Config::IniFiles->new( -file => "config.ini" );
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
my $now_string = strftime "%H:%M:%S", localtime;
#start ! 
$|++;
Start();

sub Start {
	update_titlebar("Perl-PlayServer By sctnightcore");
	Load_lib();
	print "\e[1;46;1m================================\e[0m\n";
	print "\e[1;37mPlayServer-Perl\e[0m\n";
	print "\e[1;37mby sctnightcore\e[0m\n";
	print "\e[1;37mgithub.com/sctnightcore\e[0m\n";
	print "\e[1;46;1m================================\e[0m\n";
	File::clear_oldchecksum();
	check_config();
	my $hash_data;
	my $debug = SocketClient->new();
	my $playserver = PlayServer->new( GameID => $cfg->val( 'Setting', 'GAMEID' ), ServerID => $cfg->val('Setting','SERVERID'));
	my $anticaptcha = AntiCaptcha->new( anticaptcha_key => $cfg->val('Setting','AntiCaptchakey'));
	my ($startsendagain,$success,$fail,$waitsend,$count) = (0,0,0,0,0);
	$playserver->getserver_link();	
	while (1) {
		update_titlebar('[ Count: '.$count.' | Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.' ] BY SCTNIGHTCORE');
		#my $balance = $anticaptcha->checkbalance();
		#Get checksun
		my $checksum = $playserver->getimg_saveimg();
		#debug 
		$debug->sendSocket("[Get_Checksum!]:$checksum");
		#check if have checksum file 
		if (defined $checksum) {
			#get taskID / get answer
			my ($taskid,$answer) = $anticaptcha->get_taskid_and_answer($checksum);
			#my $answer = inputfromkeyboard(); #for test ! 
			#debug
			$debug->sendSocket("[Get_Answer_TaskId!]: $answer | $taskid");	
			# remove checksum file
			File::file_remove($checksum);
			#debug 
			$debug->sendSocket("[ADD DATA!]CHECKSUM:$checksum|TASKID:$taskid|ANSWER:$answer");
			#push checksum / answer to hashdata
			push (@{$hash_data->{all_data}},{ checksum => $checksum, answer => $answer, taskid => $taskid});
			#update var
			$waitsend += 1;
			$count += 1;
			#update process title
			update_titlebar('[ Count: '.$count.' | Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.' ] BY SCTNIGHTCORE');
			#send Answer evey 61 sec
			if (time() >= $startsendagain) {
				#update var
				$waitsend -= 1;
				#send answer
				my $res_playserver = $playserver->send_answer($hash_data->{all_data}->[0]->{answer}, $hash_data->{all_data}->[0]->{checksum});
				#debug 
				$debug->sendSocket("[send_Checksum!]:$hash_data->{all_data}->[0]->{checksum} | $hash_data->{all_data}->[0]->{answer}");				
				#check res playserver
				#0 = Fail / 1 = Success
				if ($res_playserver->{'success'}) {
					print "[\e[1;37m$now_string\e[0m] - [\e[1;42;1mSUCCESS\e[0m] | [\e[1;37mCHECKSUM:\e[0m $hash_data->{all_data}->[0]->{checksum}] | [\e[1;37mANSWER:\e[0m $hash_data->{all_data}->[0]->{answer}]\n";
					$success += 1;
					#debug
					$debug->sendSocket("[send_Checksum_Success!]: $hash_data->{all_data}->[0]->{checksum} | $hash_data->{all_data}->[0]->{answer}");					
				} else {
					print "[\e[1;37m$now_string\e[0m] - [\e[1;41;1mFail\e[0m] | [\e[1;37mCHECKSUM:\e[0m $hash_data->{all_data}->[0]->{checksum}] | [\e[1;37mANSWER:\e[0m $hash_data->{all_data}->[0]->{answer}]\n";
					$fail += 1;
					#debug
					$debug->sendSocket("[send_Checksum_Fail!]: $hash_data->{all_data}->[0]->{checksum} | $hash_data->{all_data}->[0]->{answer}");
					#TODO config auto report 
					$anticaptcha->report_imgcaptcha($hash_data->{all_data}->[0]->{taskid});

				}
				#next checksum / answer for send next time
				shift @{$hash_data->{all_data}};
				#update var time for send again 
				$startsendagain = time() + $res_playserver->{'wait'} + 1;
				#update process title
				update_titlebar('[ Count: '.$count.' | Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.' ] BY SCTNIGHTCORE');
			}
			#sleep 10 sec for back to loop
			sleep 10;
		}
	}
}

sub check_config {
	my $antikey = $cfg->val('Setting','AntiCaptchakey');
	my $gameid = $cfg->val( 'Setting', 'GAMEID' );
	my $serverid = $cfg->val('Setting','SERVERID');
	if ( ( $antikey eq '' ) || ( $gameid eq '' ) || ( $serverid eq '') ) {
		print "\e[1;41;1m[Recheck config.ini]!\e[0m\n";
		sleep 10;
		exit;
	}
}

sub inputfromkeyboard {
	print "\nCaptcha is: \n";
	my $answer = <STDIN>;
	chomp $answer;
	return $answer;
}

sub update_titlebar {
	my ($msg) = @_;
	if ($^O eq 'MSWin32') {
		my $c = Win32::Console->new();
		$c->Title($msg);
	}
}

sub Load_lib {
	require Config::IniFiles;
	require HTTP::Tiny;
	require JSON::XS;
	require POSIX;
	require AntiCaptcha;
	require File;
	require PlayServer;
	require SocketClient;
	require WWW::Mechanize;
	require WebService::Antigate;
	require Term::ANSIColor;
	if ($^O eq 'MSWin32') {
		require Win32::Console::ANSI;
		require Win32::Console;
	}
	require URI::Encode;
}

1;