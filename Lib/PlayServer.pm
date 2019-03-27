package PlayServer;
use strict;
use JSON;
use HTTP::Tiny;


sub getimg_saveimg {
	my ($server) = @_;
	my $get_img = HTTP::Tiny->new( timeout => 10 )->request('POST', "http://playserver.co/index.php/Vote/ajax_getpic/$server");
	if ($get_img->{success}) {
		my $jsonone = decode_json($get_img->{content});
		my $checksum = $jsonone->{'checksum'};
		my $url = "http://playserver.co/index.php/VoteGetImage/$checksum";
		my $saveimg = HTTP::Tiny->new( timeout => 10 )->mirror($url, "img/$checksum.png");
		return ($checksum);
	} else {
		die "cannot get img from playserver\n";
		return;
	}
}


sub send_answer {
	my ($ans,$checksum,$server,$gameid,$serverid,$b) = @_;
	my $www_sendanswer = "http://playserver.co/index.php/Vote/ajax_submitpic/$server";
	my $send_answer = HTTP::Tiny->new( timeout => 10 )->request('POST', $www_sendanswer, {
	  content => "server_id=$serverid&captcha=$ans&gameid=$gameid&checksum=$checksum",
	  headers => { 
	  	'content-type' => 'application/x-www-form-urlencoded',
	  	'referer' => "http://playserver.in.th/index.php/Vote/prokud/$server"}
	});
	if ($send_answer->{success}) {
		my $jsontwo = decode_json($send_answer->{content});
		return $jsontwo;
	} else {
		die "Cannot send answer to playserver\n";
		return;
	}
}

1;