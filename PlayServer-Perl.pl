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
	print "\e[1;46;1m================================\e[0m\n";
	print "\e[1;37mPlayServer-Perl\e[0m\n";
	print "\e[1;37mby sctnightcore\e[0m\n";
	print "\e[1;37mgithub.com/sctnightcore\e[0m\n";
	print "\e[1;46;1m================================\e[0m\n";
	my ($startsendagain,$success,$fail,$waitsend) = (0,0,0,0,0);
	update_titlebar($success,$fail,$waitsend);
	my $hash_data;
	my $dir_saveimg = "$RealBin/img";
	my $dir_config = "$RealBin/config";
	my $cfg = Config::IniFiles->new( -file => "$dir_config/config.ini" ) or die "Failed to create Config::IniFiles object\n";;
	my $playserver = PlayServer->new( GameID => $cfg->val( 'Setting', 'GAMEID' ), ServerID => $cfg->val('Setting','SERVERID'), dir_saveimg => $dir_saveimg);
	my $anticaptcha = AntiCaptcha->new( anticaptcha_key => $cfg->val('Setting','AntiCaptchakey'), dir_readimg => $dir_saveimg);
	my $fs = File->new( Path => $dir_saveimg);
	$playserver->getserver_link();
	$fs->clear_oldchecksum();
	while (1) {
		my $now_string = strftime("%H:%M:%S", localtime);
		my $var = CheckVar($waitsend);
		my $balance = $anticaptcha->checkbalance($now_string);
		if ($var == 0) {
			my $checksum = $playserver->getimg_saveimg();
			my ($taskid,$answer) = $anticaptcha->get_taskid_and_answer($checksum);
			$waitsend += 1;
			push @{$hash_data},{ checksum => $checksum, answer => $answer, taskid => $taskid };
			update_titlebar($success,$fail,$waitsend);
			$fs->file_remove($checksum);
			sleep 2;
		}
		if (time >= $startsendagain) {
			$waitsend -= 1;
			my $res = $playserver->send_answer($hash_data->[0]->{answer}, $hash_data->[0]->{checksum},$now_string);
			if ($res->{'success'}) {
				$success += 1;
				open(WRITE, ">>:utf8", "$RealBin/Log/Success_Log.txt");
				print WRITE "[$now_string] - [ $hash_data->[0]->{checksum} | $hash_data->[0]->{taskid} ]\n";
				close(WRITE);		
			} else {
				$fail += 1;
				open(WRITE, ">>:utf8", "$RealBin/Log/Fail_Log.txt");
				print WRITE "[$now_string] - [ $hash_data->[0]->{checksum} | $hash_data->[0]->{taskid} ]\n";
				close(WRITE);
			}
			shift @{$hash_data};
			$startsendagain = time() + 61;
			update_titlebar($success,$fail,$waitsend);
		}
	}
}

sub CheckVar {
	my ($waitsend) = @_;
	return 1 if ($waitsend == 12);
	return 0 if ($waitsend == 0);	
}

sub update_titlebar {
	my ($success,$fail,$waitsend) = @_;
	if ($^O eq 'MSWin32') {
		my $c = Win32::Console->new();
		$c->Title('[ Success: '.$success.' | Fail: '.$fail.' | WaitSend: '.$waitsend.'(12) ] BY SCTNIGHTCORE');
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