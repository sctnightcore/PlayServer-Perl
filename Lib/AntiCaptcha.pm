package AntiCaptcha;
use WebService::Antigate;
use Data::Dumper;



sub new {
    my ($class, %args) = @_;
    my $self = {};
	$self->{wa} = WebService::Antigate->new(key => $args{anticaptcha_key});

	return bless $self, $class;
}


sub get_taskid {
	my ($self,$checksum) = @_;
	my $taskid = $self->{wa}->upload(file => "img/$checksum.png") or die $self->{wa}->errstr;
	return $taskid;	
}

sub get_answer {
	my ($self,$taskid) = @_;
	my $answer = $self->{wa}->recognize($taskid) or die $self->{wa}->errstr;
	return $answer;
}

sub checkbalance {
	my ($self) = @_;
	my $balance = $self->{wa}->balance();
	if ($balance == 0) {
		print "\e[1;41;1mAntiCaptcha balance is 0 !\e[0m\n";
		sleep 5;
		exit;
	}
	return $balance;
}

sub report_imgcaptcha {
	my ($self, $taskid) = @_;
	my $res = $self->{wa}->abuse($taskid) or die $self->{wa}->errstr;
	if ($res) {
		print "[\e[1;42;1mSUCCESS\e[0m] ReportCaptcha: $taskid\n";
	} else {
		print "[\e[1;41;1mFail\e[0m] ReportCaptcha: $taskid\n";
	}

	return $res;
}
1;