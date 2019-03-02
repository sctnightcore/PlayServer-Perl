package PlayServer;
use strict;
use JSON::XS;
use HTTP::Tiny;

sub getimg_saveimg {
	my ($server) = @_;
	my $get_img = HTTP::Tiny->new()->request('POST', "http://playserver.co/index.php/Vote/ajax_getpic/$server");
	if ($get_img->{success}) {
		my $jsonone = decode_json($get_img->{content});
		my $checksum = $jsonone->{'checksum'};
#save img
		my $url = "http://playserver.co/index.php/VoteGetImage/$checksum";
		my $saveimg = HTTP::Tiny->new()->mirror($url, "img/$checksum.png");
		return ($checksum,$jsonone);
	}
}


sub send_answer {
	my ($ans,$checksum,$server,$gameid,$serverid) = @_;
	my $www_sendanswer = "http://playserver.co/index.php/Vote/ajax_submitpic/$server";
	my %data = (
	  agent => "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.109 Safari/537.36",
	  'Referer' => "http://playserver.in.th/index.php/Vote/prokud/$server",
	  Content => "server_id=$serverid&captcha=$ans&gameid=$gameid&checksum=$checksum"
	);
	my $send_answer = HTTP::Tiny->new()->request('POST', "http://playserver.co/index.php/Vote/ajax_submitpic/$server",{content => %data});
	if ($send_answer->{success}) {
		my $jsontwo = decode_json($send_answer->{content});
		if ($jsontwo->{'success'} eq '1' ) {
			my $success =+ 1;
			return ($success);
		 } elsif ($jsontwo->{'used'} eq '1' && $jsontwo->{'success'} eq '0') {
		 	my $fail =+ 1;
		 	return ($fail);
		 } elsif ($jsontwo->{'success'} eq '0' && $jsontwo->{'used'} eq '0') {
 		 	my $fail =+ 1;
		 	return ($fail);
		}
	}
}

1;