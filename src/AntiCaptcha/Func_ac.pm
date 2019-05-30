package AntiCaptcha::Func_ac;
use strict;
use WebService::AntiCaptcha;
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
	my $res = $self->{ac}->createTask({ type => 'ImageToTextTask', body => $img }) or die $self->{ac}->errstr;
	if ( $self->{debug} == 1 ) {
		printf('\e[36m[DEBUG_AC]->[%s:%s]\e[0m\n','GET_TASK',$res->{taskId});
	}
	return $res->{taskId};
}

sub get_Answer {
	my ($self, $taskid) = @_;
	my $rand = int(rand(60));
	foreach (0..$rand) {
		my $res = $self->{ac}->getTaskResult($taskid) or die $self->{ac}->errstr;
		if ($res->{status} ne 'processing') {
			if ( $self->{debug} == 1 ) {
				printf('\e[36m[DEBUG_AC]->[%s:%s]\e[0m\n','GET_ANSWER',$res->{solution}->{text});
			}
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
	my $res = $self->{ac}->getBalance() or die $self->{ac}->errstr;
	if ( $self->{debug} == 1 ) {
		printf('\e[36m[DEBUG_AC]->[%s:%s]\e[0m\n','GET_BALANCE',$res->{balance});
	}
	if ($res->{balance} == 0 ) {
		print "Balance is 0\n";
		sleep 10;
		exit;
	}
	return $res->{balance};
}

sub report_Taskid {
	my ($self, $taskid) = @_;
	my $res = $self->{ac}->reportIncorrectImageCaptcha($taskid) or die $self->{ac}->errstr;
	if ( $self->{debug} == 1) {
		printf('\e[36m[DEBUG_AC]->[%s:%s]\e[0m\n','REPORT_TASKID',$res->{status});
	}
	return $res;
}

1;