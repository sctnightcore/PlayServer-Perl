package Core_Logic;
use strict;
use AntiCaptcha::Func_ac;
use PlayServer::Func_ps;
use Time::HiRes qw(time usleep);
use Interface::Console;
use Commands;
use Utils;
use Var qw(  $success_count $fail_count $report_count $report_count_success $report_count_fail $interface $func_ac $func_ps $quit $gameid $serverid);
use Data::Dumper;
use URI::Encode qw(uri_encode uri_decode);

sub new {
	my ($class, %args) = @_;
	my $self = {};
	$self->{path} = $args{Path};
	$self->{antikey} = $args{Anticaptcha_key};
	$self->{gameID} = $args{GameID};
	$self->{ServerUrl} = $args{ServerUrl};
	$self->{ServerID} = $args{ServerID};
	$self->{debug} = $args{Debug};
	$serverid = $self->{ServerID};
	$gameid = $self->{gameID};
	return bless $self, $class;
}

sub MainLoop {
	my ($self) = @_;
	$interface = Interface::Console->new();
	$func_ac = AntiCaptcha::Func_ac->new( AntiKey => $self->{antikey}, Debug => $self->{debug});
	$func_ps = PlayServer::Func_ps->new( ServerUrl => $self->{ServerUrl}, ServerID => $self->{ServerID}, GameID => $self->{gameID}, Debug => $self->{debug});
	$interface->title("PlayServer Perl Vote by sctnightcore");
	$interface->writeoutput("\t===============================\n",'white');
	$interface->writeoutput("\tPlayServer Vote by sctnightcore\n",'white');
	$interface->writeoutput("\tgithub.com/sctnightcore\n",'white');
	$interface->writeoutput("\t===============================\n",'white');
	Utils::title_count();
	my $nexttime = 0;
	while ($quit != 1) {
		if (defined(my $input = $interface->getInput(0))) {
			$interface->writeoutput("Commands Input: $input\n");
		}
		my $balance = $func_ac->get_Balance();
		if (time() >= $nexttime) {
			if (defined(my $image = $func_ps->get_Image())) {
				Utils::title_count();
				if (defined(my $imagedata = $func_ps->get_ImageData($image))) {
					my $taskID = $func_ac->get_Task($imagedata);
					my $res_TaskID = $func_ac->get_Answer($taskID);
					if (defined(my $res_sendanswer = $func_ps->send_Image($res_TaskID->{answer}, $image))) {
						if ($res_sendanswer->{success}) {
							$success_count += 1;
							my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
							my $time = sprintf('%02d:%02d:%02d',$hour, $min, $sec);					
							my $succes_text = sprintf("[%s] - [%s] - [CHECKSUM:%s] - [ANSWER:%s]\n", $time, 'SUCCESS', $image, $res_TaskID->{answer});
							$interface->writeoutput($succes_text,'green');
						} else {
							#todo
							$fail_count += 1;
							my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
							my $time = sprintf('%02d:%02d:%02d',$hour, $min, $sec);
							my $fail_text = sprintf("[%s] - [%s] - [CHECKSUM:%s] - [ANSWER:%s]\n", $time, 'FAIL', $image, $res_TaskID->{answer});
							$interface->writeoutput($fail_text,'red');
							my $report = $func_ac->report_Taskid($taskID);
							if ( $report->{status} eq 'success' && $report->{errorId} == 0 ) {
								$report_count += 1;
								$report_count_success += 1;
								$interface->writeoutput("[REPORT-CAPTCHA-SUCCESS] TASKID:$taskID | ANSWER: $res_TaskID->{answer}\n",'green');
							} else {
								$report_count += 1;
								$report_count_fail += 1;
								$interface->writeoutput("[REPORT-CAPTCHA-FAIL] TASKID:$taskID | ANSWER: $res_TaskID->{answer}\n",'red');
							}
						}
						Utils::title_count();
						my $timesleep = defined($res_sendanswer->{wait}) ? $res_sendanswer : 61;
						$nexttime = time() + $timesleep;
					}
				}
			}
		}
	}
}
1;