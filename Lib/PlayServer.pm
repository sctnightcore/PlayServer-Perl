package PlayServer;
use strict;
use JSON;
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
		return ($checksum);
	}
}


sub send_answer {
	my ($ans,$checksum,$server,$gameid,$serverid,$b) = @_;
	my $www_sendanswer = "http://playserver.co/index.php/Vote/ajax_submitpic/$server";
	my $send_answer = HTTP::Tiny->new->request('POST', $www_sendanswer, {
	  content => "server_id=$serverid&captcha=$ans&gameid=$gameid&checksum=$checksum",
	  headers => { 
	  	'content-type' => 'application/x-www-form-urlencoded',
	  	'referer' => "http://playserver.in.th/index.php/Vote/prokud/$server"}
	});
	if ($send_answer->{success}) {
		my $jsontwo = decode_json($send_answer->{content});
		if ($jsontwo->{'success'} eq '1') {
			printf("[Money:%s] | [Success] | %5s.png | %6s | Wait:%3s|\n",$b,$checksum,$ans,$jsontwo->{'wait'});
		 } else {
		 	printf("[Money:%s] | [Fail] | %5s.png | %6s | Wait:%3s|\n",$b,$checksum,$ans,$jsontwo->{'wait'});
		 }
	}
}

1;