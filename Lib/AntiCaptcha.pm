package AntiCaptcha;

use WebService::Antigate::V2;

sub anti_captcha {
	my ($checksum,$antikey) = @_;
	my $recognizer = WebService::Antigate::V2->new(key => $antikey , api_version => 2);
	my $ans = $recognizer->upload_and_recognize(file => "img/$checksum.png") or die $recognizer->errstr;
	return $ans;
}

sub checkmoney {
	my ($antikey) = @_;
	my $recognizer = WebService::Antigate::V2->new(key => $antikey , api_version => 2);
	my $b = $recognizer->balance();
	return $b;
}

1;