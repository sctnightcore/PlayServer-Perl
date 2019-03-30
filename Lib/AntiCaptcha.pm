package AntiCaptcha;
use WebService::Antigate;
use Data::Dumper;



sub new {
    my ($class, %args) = @_;
    my $self = {};
    $self->{key} = $args{anticaptcha_key}; 
	return bless $self, $class;
}


sub get_answer {
	my ($self,$checksum) = @_;
	my $recognizer = WebService::Antigate->new(key => $self->{key});
	my $answer = $recognizer->upload_and_recognize(file => "img/$checksum.png") or die $recognizer->errstr;
	print "[GetAnswer]: $answer\n";
	return $answer;
}

1;