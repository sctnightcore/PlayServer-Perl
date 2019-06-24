package AntiCaptcha::Func_ac;
use strict;
use WebService::AntiCaptcha;
use Var qw($interface);
use Win32::Console::ANSI;


sub new {
	my ($class, %args) = @_;
	my $self = {};
	$self->{key} = $args{AntiKey};
	$self->{debug} = $args{Debug};
	$self->{ac} = WebService::AntiCaptcha->new( 
		clientKey => $self->{key} 
	);
	return bless $self, $class;
}

sub get_Task {
	my ($self, $img) = @_;
	my $res = $self->{ac}->createTask({ 
		type => 'ImageToTextTask', 
		body => $img 
	}) or $interface->writeoutput("[ERROR_get_Task]$self->{ac}->errstr\n");
	return $res->{taskId};
}

sub get_Answer {
	my ($self, $taskid) = @_;
	my $rand = int(rand(60));
	foreach (0..$rand) {
		my $res = $self->{ac}->getTaskResult($taskid) or $interface->writeoutput("[ERROR_get_Answer]$self->{ac}->errstr\n");
		if ($res->{status} ne 'processing') {
			return ({
				answer => $res->{solution}->{text},
				cost => $res->{cost}
			});	
		} else {
			sleep(5);
		}
	}
}

sub get_Balance {
	my ($self) = @_;
	my $res = $self->{ac}->getBalance() or $interface->writeoutput("[ERROR_get_Balance]$self->{ac}->errstr\n");
	if ($res->{balance} == 0) {
		$interface->writeoutput("[AntiCaptCha] Balance is 0.\n");
		$interface->writeoutput("Press ENTER to exit.\n");
		<STDIN>;
		exit;
	}	
	return $res->{balance};
}

sub report_Taskid {
	my ($self, $taskid) = @_;
	my $res = $self->{ac}->reportIncorrectImageCaptcha($taskid) or $interface->writeoutput("[ERROR_report_Taskid]$self->{ac}->errstr\n");;
	return $res;
}

1;