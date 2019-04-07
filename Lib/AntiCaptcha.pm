package AntiCaptcha;
use WebService::Antigate;
use Data::Dumper;



sub new {
    my ($class, %args) = @_;
    my $self = {};
    $self->{wa} = WebService::Antigate->new(key => $args{anticaptcha_key});
	return bless $self, $class;
}

sub get_answer {
	my ($self,$checksum) = @_;
	my $answer = $self->{wa}->upload_and_recognize(file => "img/$checksum.png") or die $self->{wa}->errstr;
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
1;