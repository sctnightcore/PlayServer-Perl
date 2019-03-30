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

1;