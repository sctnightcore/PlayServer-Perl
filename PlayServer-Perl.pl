use strict;
use warnings;
use Config::IniFiles;
use JSON::XS;
use Data::Dumper;
use Win32::Console::ANSI;
use Win32::Console;
use WWW::Mechanize;
use POSIX;
use URI::Encode qw(uri_encode uri_decode);
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use AntiCaptcha;
use File;
use PlayServer;

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
	print "[\e[1;37m$now_string\e[0m] - Clear old Checksum File..";
	File::clear_oldcheckfile();
	print "[\e[1;37m$now_string\e[0m] - Loading Config..";
	checkconfig();
	print "[\e[1;37m$now_string\e[0m] - Get Url Server..";
	my $linkserver = paser_PlayServer();
	my $playserver = PlayServer->new( Server_Url => $linkserver, GameID => $cfg->val( 'Setting', 'GAMEID' ), ServerID => $cfg->val('Setting','SERVERID'));
	my $anticaptcha = AntiCaptcha->new( anticaptcha_key => $cfg->val('Setting','AntiCaptchakey'));
	my $startsendagain = 0;
	my $success = 0;
	my $fail = 0;
	my $waitsend = 0;
	my $count = 0;
	my $hash_data;
	while () {
		update_titlebar('[ Count: '.$count.' | Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.' ] BY SCTNIGHTCORE');
		$anticaptcha->checkbalance();
		#Get checksun
		my $checksum = $playserver->getimg_saveimg();
		#check if have checksum file 
		if (defined $checksum) {
			#get taskID / get answer
			my ($taskid,$answer) = $anticaptcha->get_taskid_and_answer($checksum);
			#my $answer = inputfromkeyboard(); #for test ! 
			# remove checksum file
			File::file_remove($checksum);		
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
				#check res playserver
				#0 = Fail / 1 = Success
				if ($res_playserver->{'success'}) {
					print "[\e[1;37m$now_string\e[0m] - [\e[1;42;1mSUCCESS\e[0m] | [\e[1;TASKID:\e[0m $hash_data->{all_data}->[0]->{taskid}] | [\e[1;37mCHECKSUM:\e[0m $hash_data->{all_data}->[0]->{checksum}.png] | [\e[1;37mANSWER:\e[0m $hash_data->{all_data}->[0]->{answer}]\n";
					$success += 1;	
				} else {
					print "[\e[1;37m$now_string\e[0m] - [\e[1;41;1mFail\e[0m] | [\e[1;TASKID:\e[0m $hash_data->{all_data}->[0]->{taskid}] | [\e[1;37mCHECKSUM:\e[0m $hash_data->{all_data}->[0]->{checksum}.png] | [\e[1;37mANSWER:\e[0m $hash_data->{all_data}->[0]->{answer}]\n";
					$fail += 1;
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
		} else {
			print "\e[1;41;1mCannot Get Checksum from PlayServer\e[0m\n";
			return;
		}
	}
}

sub checkconfig {
	my $antikey = $cfg->val('Setting','AntiCaptchakey');
	my $gameid = $cfg->val( 'Setting', 'GAMEID' );
	my $serverid = $cfg->val('Setting','SERVERID');
	if ( ( $antikey eq '' ) || ( $gameid eq '' ) || ( $serverid eq '') ) {
		print "\e[1;41;1mFail [Recheck config.ini]!\e[0m\n";
		sleep 10;
		exit;
	} else {
		sleep 1;
		print "\e[1;42;1mDone\e[0m\n";
	}
}

sub inputfromkeyboard {
	print "\nCaptcha is: \n";
	my $answer = <STDIN>;
	chomp $answer;
	return $answer;
}

sub paser_PlayServer {
	my $mech = WWW::Mechanize->new();
	my $k;
	$mech->get( 'https://playserver.in.th/index.php/Server/'.$cfg->val('Setting','SERVERID'));
	my @links = $mech->find_all_links(url_regex => qr/prokud\.*/);
	for my $link ( @links ) {
		my $url = $link->url;
		my @result = split '/', $url;
		$k = $result[6];
	}
	print "\e[1;42;1mDone\e[0m\n";
	return uri_encode($k);
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