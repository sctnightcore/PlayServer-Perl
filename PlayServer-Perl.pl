use strict;
use Config::IniFiles;
use Win32::Console::ANSI;
use Win32::Console;
use POSIX;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use AntiCaptcha;
use File;
use PlayServer;
use SocketClient;
#start ! 
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
	my $hash_data;
	my $debug = SocketClient->new();
	my $now_string = strftime "%H:%M:%S", localtime;
	my $cfg = Config::IniFiles->new( -file => "$RealBin/config/config.ini" ) or die "Failed to create Config::IniFiles object\n";;
	my $playserver = PlayServer->new( GameID => $cfg->val( 'Setting', 'GAMEID' ), ServerID => $cfg->val('Setting','SERVERID'), dir_saveimg => $RealBin);
	my $anticaptcha = AntiCaptcha->new( anticaptcha_key => $cfg->val('Setting','AntiCaptchakey'), dir_readimg => $RealBin);
	my ($startsendagain,$success,$fail,$waitsend,$count) = (0,0,0,0,0);
	$playserver->getserver_link();	
	while (1) {
		update_titlebar('[ Count: '.$count.' | Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.' ] BY SCTNIGHTCORE');
		my $balance = $anticaptcha->checkbalance();
		if ($balance == 0) {
			print "[\e[1;37m$now_string\e[0m] - \e[1;41;1mAntiCaptcha balance is 0 !\e[0m\n";
			sleep 5;
			exit;		
		}
		#Get checksun
		my $checksum = $playserver->getimg_saveimg();
		#debug 
		$debug->sendSocket("[Get_Checksum!]:$checksum") if ( $cfg->val( 'Setting', 'SocketDebug' ) eq '1');
		#check if have checksum file 
		if (defined $checksum) {
			#get taskID / get answer
			my ($taskid,$answer) = $anticaptcha->get_taskid_and_answer($checksum);
			#my $answer = inputfromkeyboard(); #for test ! 
			#debug
			$debug->sendSocket("[Get_Answer_TaskId!]: $answer | $taskid") if ( $cfg->val( 'Setting', 'GAMEID' ) eq '1');	
			# remove checksum file
			File::file_remove($checksum);
			#debug 
			$debug->sendSocket("[ADD DATA!]CHECKSUM:$checksum|TASKID:$taskid|ANSWER:$answer") if ( $cfg->val( 'Setting', 'SocketDebug' ) eq '1');
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
				#debug 
				$debug->sendSocket("[send_Checksum!]:$hash_data->{all_data}->[0]->{checksum} | $hash_data->{all_data}->[0]->{answer}") if ( $cfg->val( 'Setting', 'SocketDebug' ) eq '1');				
				#send answer
				my $res_playserver = $playserver->send_answer($hash_data->{all_data}->[0]->{answer}, $hash_data->{all_data}->[0]->{checksum});
				if (defined($res_playserver)) {
					#check res playserver
					#0 = Fail / 1 = Success
					if ($res_playserver->{'success'}) {
						print "[\e[1;37m$now_string\e[0m] - [\e[1;42;1mSUCCESS\e[0m] | [\e[1;37mCHECKSUM:\e[0m $hash_data->{all_data}->[0]->{checksum}] | [\e[1;37mANSWER:\e[0m $hash_data->{all_data}->[0]->{answer}]\n";
						$success += 1;
						#debug
						$debug->sendSocket("[send_Checksum_Success!]: $hash_data->{all_data}->[0]->{checksum} | $hash_data->{all_data}->[0]->{answer}") if ( $cfg->val( 'Setting', 'SocketDebug' ) eq '1');					
					} else {
						print "[\e[1;37m$now_string\e[0m] - [\e[1;41;1mFail\e[0m] | [\e[1;37mCHECKSUM:\e[0m $hash_data->{all_data}->[0]->{checksum}] | [\e[1;37mANSWER:\e[0m $hash_data->{all_data}->[0]->{answer}]\n";
						$fail += 1;
						#debug
						$debug->sendSocket("[send_Checksum_Fail!]: $hash_data->{all_data}->[0]->{checksum} | $hash_data->{all_data}->[0]->{answer}") if ( $cfg->val( 'Setting', 'SocketDebug' ) eq '1');
=put						
						#TODO config auto report 
						my $res_report = $anticaptcha->report_imgcaptcha($hash_data->{all_data}->[0]->{taskid});
						if (defined($res_report)) {
							print "[\e[1;37m$now_string\e[0m] - [\e[1;42;1mSUCCESS\e[0m] ReportCaptcha: $taskid\n";
						} else {
							print "[\e[1;37m$now_string\e[0m] - [\e[1;41;1mFail\e[0m] ReportCaptcha: $taskid\n";
						}
						
=cut					
					}				
				} else {
					print "\e[1;41;1m[Cannot get send_Answer JSON from PlayServer.in.th]\e[0m\n";
					redo;
				}
				#next checksum / answer for send next time
				shift @{$hash_data->{all_data}};
				#update var time for send again 
				my $sleep = defined($res_playserver->{'wait'}) ? $res_playserver->{'wait'} : 61;
				$startsendagain = time() + $sleep + 1;
				#update process title
				update_titlebar('[ Count: '.$count.' | Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.' ] BY SCTNIGHTCORE');
			}
			#sleep 10 sec for back to loop
			sleep 10;
		} else {
			print "\e[1;41;1m[Cannot get Checksum JSON from PlayServer.in.th]\e[0m\n";
			redo;
		}
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