use strict;
use Config::IniFiles;
use Win32::Console::ANSI;
use Win32::Console;
use Data::Dumper;
use POSIX;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use AntiCaptcha;
use File;
use PlayServer;

sub __start {
	print "\e[1;46;1m================================\e[0m\n";
	print "\e[1;37mPlayServer-Perl\e[0m\n";
	print "\e[1;37mby sctnightcore\e[0m\n";
	print "\e[1;37mgithub.com/sctnightcore\e[0m\n";
	print "\e[1;46;1m================================\e[0m\n";
	my ($success,$fail) = (0,0);
	my $dir_saveimg = "$RealBin/img";
	my $dir_config = "$RealBin/config";
	my $cfg = Config::IniFiles->new( -file => "$dir_config/config.ini" ) or die "Failed to create Config::IniFiles object\n";;
	my $playserver = PlayServer->new( GameID => $cfg->val( 'Setting', 'GAMEID' ), ServerID => $cfg->val('Setting','SERVERID'), dir_saveimg => $dir_saveimg);
	my $anticaptcha = AntiCaptcha->new( anticaptcha_key => $cfg->val('Setting','AntiCaptchakey'), dir_readimg => $dir_saveimg);
	my $fs = File->new( Path => $dir_saveimg);
	my $c = Win32::Console->new();
	$playserver->getserver_link();
	$fs->clear_oldchecksum();
	while (1) {
		my $title = sprintf("[ Success: %-3s | Fail: %-3s ]-----[ By SCTNIGHTCORE ]", $success,$fail);
		my $now_string = strftime("%H:%M:%S", localtime);
		my $balance = $anticaptcha->checkbalance($now_string);
		my $checksum = $playserver->getimg_saveimg();
		my ($taskid,$answer) = $anticaptcha->get_taskid_and_answer($checksum);
		$fs->file_remove($checksum);
		my $res = $playserver->send_answer($answer, $checksum,$now_string);
		if ($res->{'success'}) {
			$success += 1;
			open(WRITE, ">>:utf8", "$RealBin/Log/Success_Log.txt");
			print WRITE "[$now_string] - [ $checksum | $taskid | $answer ]\n";
			close(WRITE);		
		} else {
			$fail += 1;
			open(WRITE, ">>:utf8", "$RealBin/Log/Fail_Log.txt");
			print WRITE "[$now_string] - [ $checksum | $taskid | $answer ]\n";
			close(WRITE);
		}
		$c->Title($title);
		sleep($res->{'wait'})
	}
}


__start() if (! $^0 eq 'MSWin32');
1;