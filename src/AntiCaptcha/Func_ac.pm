package AntiCaptcha::Func_ac;
use strict;
use WebService::AntiCaptcha;


sub new {
	my ($class, %args) = @_;
	my $self = {};
	$self->{key} = $args{AntiKey};
	$self->{ac} = WebService::AntiCaptcha->new( clientKey => $self->{key} );
	return bless $self, $class;
}

sub get_Task {
	my ($self, $img) = @_;
	my $res = $self->{ac}->createTask({
		type => 'ImageToTextTask',
		body => $img
	}) or die $self->{ac}->errstr;
	return $res->{taskId};
}

sub get_Answer {
	my ($self, $taskid) = @_;
	for my $i (rand(60)) {
		my $res = $self->{ac}->getTaskResult($taskid) or die $self->{ac}->errstr;
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
	my $res = $self->{ac}->getBalance() or die $self->{ac}->errstr;
	if ($res->{balance} == 0 ) {
		sleep 10;
		exit;
	}
	return $res->{balance};
}

sub report_Taskid {
	my ($self, $taskid) = @_;
	my $res = $self->{ac}->reportIncorrectImageCaptcha($taskid) or die $self->{ac}->errstr;
	return $res;
}

1;