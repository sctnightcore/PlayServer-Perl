package AntiCaptcha;
use WebService::Antigate::V2;
my $recognizer = WebService::Antigate::V2->new(key => $antikey , api_version => 2);

sub anti_captcha {
	my ($checksum,$antikey) = @_;
	my $ans = $recognizer->upload_and_recognize(file => "img/$checksum.png") or die $recognizer->errstr;
	return $ans;
}

sub checkmoney {
	my ($antikey) = @_;
	my $b = $recognizer->balance();
	return $b;
}

1;