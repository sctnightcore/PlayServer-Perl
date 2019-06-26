package Core_Logic;
use strict;
use Time::HiRes qw(time usleep);
use Commands;
use Utils;
use Var;

sub new {
	my ($class, %args) = @_;
	my $self = {};
	$self->{path} = $args{Path};
	$path = $self->{path};
	return bless $self, $class;
}

sub MainLoop {
	my ($self) = @_;
	Utils::Logic_Start();
	my $nexttime = 0;
	while ($quit != 1) {
		if (defined(my $input = $interface->getInput(0))) {
			Commands::Main($input);
		}
		my $balance = $func_ac->get_Balance();
		if (time() >= $nexttime) {
			Utils::title_count();
			if (defined(my $image = $func_ps->get_Image())) {
				if (defined(my $imagedata = $func_ps->get_ImageData($image))) {
					my $taskID = $func_ac->get_Task($imagedata);
					my $res_TaskID = $func_ac->get_Answer($taskID);
					if (defined(my $res_sendanswer = $func_ps->send_Image($res_TaskID->{answer}, $image))) {
						if ($res_sendanswer->{success}) {
							$success_count += 1;
							my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();			
							my $succes_text = sprintf("[%02d:%02d:%02d] - [%s] - [CHECKSUM:%s] - [ANSWER:%s]\n", $hour, $min, $sec, 'SUCCESS', $image, $res_TaskID->{answer});
							$interface->writeoutput($succes_text,'green');
						} else {
							#todo
							$fail_count += 1;
							my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
							my $fail_text = sprintf("[%02d:%02d:%02d] - [%s] - [CHECKSUM:%s] - [ANSWER:%s]\n", $hour, $min, $sec, 'FAIL', $image, $res_TaskID->{answer});
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