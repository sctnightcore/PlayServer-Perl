package AntiCaptcha;

use WebService::Antigate::V2;

sub anti_captcha {
	my ($checksum,$antikey) = @_;
	my $recognizer = WebService::Antigate::V2->new(key => $antikey , api_version => 2);
	my $ans = $recognizer->upload_and_recognize(file => "img/$checksum.png") or die $recognizer->errstr;
	my $b = $recognizer->balance();

	if ($b == '0') {
		print "You balance in Anti-Captcha.com is $b ! \n";
		exit;
	}
	
	return ($ans,$b);
}

1;