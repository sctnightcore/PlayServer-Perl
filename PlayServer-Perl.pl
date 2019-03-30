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

#START#
Start();
sub Start {
	Loadlib();
	print "================================\n";
	print "PlayServer-Perl\n";
	print "by sctnightcore\n";
	print "github.com/sctnightcore\n";
	print "================================\n";
	my $playserver = PlayServer->new( Server_Url => $cfg->val('Setting','URL'), GameID => $cfg->val( 'Setting', 'GAMEID' ), ServerID => $cfg->val('Setting','SERVERID'));
	my $anticaptcha = AntiCaptcha->new( anticaptcha_key => $cfg->val('Setting','AntiCaptchakey'));
	while () {
		my $checksum = $playserver->getimg_saveimg();
		my $answer = $anticaptcha->get_answer($checksum); # get ans
		$playserver->send_answer($answer);
		File::file_remove($checksum);
		sleep 61;
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