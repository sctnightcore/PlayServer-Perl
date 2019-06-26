package AntiCaptcha::Func_ac;
use strict;
use WebService::AntiCaptcha;
use Var;

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
	});
	unless($res) {
		$interface->writeoutput("[ERROR_get_Task] $self->{ac}->errstr\n");
	}
	return $res->{taskId};
}

sub get_Answer {
	my ($self, $taskid) = @_;
	my $rand = int(rand(60));
	for (0..$rand) {
		my $res = $self->{ac}->getTaskResult($taskid);
		unless($res) {
			$interface->writeoutput("[ERROR_get_Answer] $self->{ac}->errstr\n");
		}
		if ($res->{status} ne 'processing') {
			return ({
				answer => $res->{solution}->{text},
				cost => $res->{cost}
			});	
		}
	}
}

sub get_Balance {
	my ($self) = @_;
	my $res = $self->{ac}->getBalance();
	unless($res) {
		$interface->writeoutput("[ERROR_get_Balance] $self->{ac}->errstr\n");
	}
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
	my $res = $self->{ac}->reportIncorrectImageCaptcha($taskid);
	unless($res) {
		$interface->writeoutput("[ERROR_report_Taskid] $self->{ac}->errstr\n");
	}
	return $res;
}

sub get_QueueStats {
	my ($self) = @_;
	my $res = $self->{ac}->queueId(1);
	unless($res) {
		$interface->writeoutput("[ERROR_get_QueueStats] $self->{ac}->errstr\n");
	} else {
		return $res;
	}
}
1;