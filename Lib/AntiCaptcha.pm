package AntiCaptcha;
use WebService::Antigate;


sub anti_captcha {
	my ($checksum,$antikey) = @_;
	my $recognizer = WebService::Antigate->new(key => $antikey);
	my $ans = $recognizer->upload_and_recognize(file => "img/$checksum.png") or die $recognizer->errstr;
	return $ans;
}

sub checkmoney {
	my ($antikey) = @_;
	my $recognizer = WebService::Antigate->new(key => $antikey);
	my $b = $recognizer->balance();
	return $b;
}

1;