package Core_Logic;
use strict;
use AntiCaptcha::Func_ac;
use PlayServer::Func_ps;
use interface::Console;
use Win32::Console::ANSI;
use Commands;
use Var qw(  $success_count $fail_count $report_count $report_count_success $report_count_fail $interface $func_ac $func_ps $quit);
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
	return bless $self, $class;
}

sub MainLoop {
	my ($self) = @_;
	$interface = interface::Console->new();
	#$func_ac = AntiCaptcha::Func_ac->new( AntiKey => $self->{antikey}, Debug => $self->{debug});
	$func_ps = PlayServer::Func_ps->new( ServerUrl => $self->{ServerUrl}, ServerID => $self->{ServerID}, GameID => $self->{gameID}, Debug => $self->{debug});
	$interface->writeoutput("\t===============================\n");
	$interface->writeoutput("\tPlayServer Vote by sctnightcore\n");
	$interface->writeoutput("\tgithub.com/sctnightcore\n");
	$interface->writeoutput("\t===============================\n");
	while ($quit != 1) {
		usleep(50000);
		if (defined(my $input = $interface->getInput(0)) {
			#Commands::Main($input);
			$interface->writeoutput("Commands Input: $input\n");
		}
=put
		my $balance = $func_ac->get_Balance();
		if ($balance == 0) {
			$interface->writeoutput("[AntiCaptCha] Balance is 0.\n");
			$interface->writeoutput("Press ENTER to exit.\n");
			<STDIN>;
			exit;
		}
=cut
		if (defined(my $image = $func_ps->get_Image())) {
=put
			my $taskID = $func_ac->get_Task($image->{base64});
			my $res_TaskID = $func_ac->get_Answer($taskID);
=cut
			my $taskID->{answer} = 'RGERG';	
			if (defined(my $res_sendanswer = $func_ps->send_Image($res_TaskID->{answer},$image->{checksum}))) {
				if ($res_sendanswer->{success}) {
					$success_count += 1;
					my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
					my $time = sprintf('%02d:%02d:%02d',$hour, $min, $sec);					
					my $succes_text = sprintf("[\e[1;37m%s\e[0m] - [\e[1;42;1m%s\e[0m] - [CHECKSUM:%s] - [ANSWER:%s]\n", $time, 'SUCCESS', $checksum, $answer);
					$interface->writeoutput($succes_text);
				} else {
					#todo
					$fail_count += 1;
					my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
					my $time = sprintf('%02d:%02d:%02d',$hour, $min, $sec);
					my $fail_text = sprintf("[\e[1;37m%s\e[0m] - [\e[1;41;1m%s\e[0m] - [CHECKSUM:%s] - [ANSWER:%s]\n", $time, 'FAIL', $checksum, $answer);
					$interface->writeoutput($fail_text);
=put
					my $report = $self->ac_reportTaskid($taskID);
					if ( $report->{status} eq 'success' && $report->{errorId} == 0 ) {
						$report_count += 1;
						$report_count_success += 1;
						$interface->writeoutput("[REPORT-CAPTCHA-SUCCESS] TASKID:$taskID | ANSWER: $res_TaskID->{answer}\n");
					} else {
						$report_count += 1;
						$report_count_fail += 1;
						$interface->writeoutput("[REPORT-CAPTCHA-FAIL] TASKID:$taskID | ANSWER: $res_TaskID->{answer}\n");
					}
=cut
				}
				sleep($res_sendanswer->{wait} ? $res_sendanswer->{wait} : 61);
			} else {
				sleep(5);
			}
		} else {
			sleep(5);
		}
	}
}
1;