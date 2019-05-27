package Core;
use strict;
use AntiCaptcha::Func_ac;
use PlayServer::Func_ps;
use Utils::Func_us;
use Utils::Var qw( $success_count $fail_count $report_count $report_count_success $report_count_fail );
use Config::IniFiles;
use Data::Dumper;
use Win32::Console::ANSI;
use POSIX qw/strftime/;

$|++;

sub Core_Logic {
	my ($path) = @_;
	my $cfg = Config::IniFiles->new( -file => "$path/Config/config.ini" ) or die "Failed to create Config::IniFiles object\n";
	my $url = PlayServer::Func_ps::get_Url($cfg->val('Setting', 'SERVERID'));
	my $ps = PlayServer::Func_ps->new( ServerUrl => $url, ServerID => $cfg->val('Setting', 'SERVERID'), GameID => $cfg->val('Setting', 'GAMEID'));
	my $ac = AntiCaptcha::Func_ac->new( AntiKey => $cfg->val('Setting', 'AntiCaptchakey'));
	my $us = Utils::Func_us->new();
	while (1) {
		$us->update_score();
		my $balance = $ac->get_Balance();
		my $img_ps = $ps->get_Image();
		if (defined($img_ps)) {
			my $task_id = $ac->get_Task($img_ps->{base64});
			my $task_res = $ac->get_Answer($task_id);
			my $res_ps = $ps->send_Image($task_res->{answer}, $img_ps->{checksum});
			if (defined($res_ps)) {
				if ($res_ps->{success}) {
					my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
					my $time = sprintf('%02d:%02d:%02d',$hour, $min, $sec);
					printf("[\e[1;37m%s\e[0m] - [\e[1;42;1m%s\e[0m] - [CHECKSUM:%s] - [ANSWER:%s]\n", $time, 'SUCCESS', $img_ps->{checksum}, $task_res->{answer});
					$success_count += 1;
				} else {
					my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
					my $time = sprintf('%02d:%02d:%02d',$hour, $min, $sec);
					printf("[\e[1;37m%s\e[0m] - [\e[1;41;1m%s\e[0m] - [CHECKSUM:%s] - [ANSWER:%s]\n", $time, 'FAIL', $img_ps->{checksum}, $task_res->{answer});
					$fail_count += 1;
					my $report = $ac->report_Taskid($task_id);
					if ($report->{status} eq 'success' && $report->{errorId} == 0) {
						printf("[\e[1;37m%s\e[0m] - [\e[1;42;1m%s\e[0m] - [REPORT:%s]\n", $time, 'SUCCESS', $task_id);
						$report_count += 1;
						$report_count_success += 1;
					} else {
						printf("[\e[1;37m%s\e[0m] - [\e[1;41;1m%s\e[0m] - [REPORT:%s]\n", $time, 'FAIL', $task_id);
						$report_count += 1;
						$report_count_fail += 1;
					}
				}
				sleep($res_ps->{'wait'});
				$us->update_score();
			} else {
				sleep(5);
			}
		} else {
			sleep(5);
		}	

	}
}


1;