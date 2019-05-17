package AntiCaptcha;
use WebService::Antigate;
use Data::Dumper;



sub new {
    my ($class, %args) = @_;
    my $self = {};
	$self->{wa} = WebService::Antigate->new(key => $args{anticaptcha_key});
	$self->{dir_readimg} = $args{dir_readimg};
	return bless $self, $class;
}


sub get_taskid_and_answer {
	my ($self,$checksum) = @_;
	my $taskid = $self->{wa}->upload(file => "$self->{dir_readimg}/$checksum.png");
	unless($taskid) {
      print "\e[1;41;1mError while uploading captcha\e[0m: ", $self->{wa}->errno, " (", $self->{wa}->errstr, ")";
	}
	my $answer = $self->{wa}->recognize($taskid);
	unless($answer) {
      print "\e[1;41;1mError while recognizing captcha\e[0m: ", $self->{wa}->errno, " (", $self->{wa}->errstr, ")";
	}
	return ($taskid,$answer) if (defined($taskid) && defined($answer));	
}

sub checkbalance {
	my ($self,$time) = @_;
	my $balance = $self->{wa}->balance();
	if ($balance == 0) {
		print "[\e[1;37m$time\e[0m] - \e[1;41;1mAntiCaptcha balance is 0 !\e[0m\n";
		sleep 5;
		exit;
	}
	return $balance if defined($balance);
}

sub report_imgcaptcha {
	my ($self, $taskid) = @_;
	my $res = $self->{wa}->abuse($taskid) or die $self->{wa}->errstr;
	return $res if defined($res);
}
1;