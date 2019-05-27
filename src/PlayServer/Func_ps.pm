package PlayServer::Func_ps;
use strict;
use JSON::XS;
use Data::Dumper;
use HTTP::Headers;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST GET);
use MIME::Base64;
use WWW::Mechanize;
use URI::Encode qw(uri_encode uri_decode);

sub new {
	my ($class, %args) = @_;
	my $self = {};
	$self->{ServerUrl} = $args{ServerUrl};
	$self->{ServerID} = $args{ServerID};
	$self->{GameID} = $args{GameID};
	$self->{debug} = $args{Debug};
	$self->{headers} = HTTP::Headers->new( 'Origin' => 'http://playserver.in.th', 'Referer' => 'http://playserver.in.th/index.php/Vote/prokud/'.$self->{ServerUrl}, 'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8');
	$self->{ua} = LWP::UserAgent->new( agent => 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36', default_headers => $self->{headers});
	return bless $self, $class;
}

sub get_Image {
	my ($self) = @_;
	my $req_checksum = POST 'http://playserver.co/index.php/Vote/ajax_getpic/'.$self->{ServerUrl};
	my $response_checksum = $self->{ua}->request($req_checksum);
	if ($response_checksum->is_success) {
		my $response_checksum_json = decode_json($response_checksum->decoded_content);
		my $req_img = GET 'http://playserver.co/index.php/VoteGetImage/'.$response_checksum_json->{'checksum'};
		my $response_img = $self->{ua}->request($req_img);
		if ( $response_img->is_success) {
			return ({
				checksum => $response_checksum_json->{'checksum'},
				base64 => encode_base64($response_img->content)
			});
		} else {
			print("[ERROR]: 503 Service Temporarily Unavailable [cannot get img data]\n");
			return;
		}
	} else {
		print("[ERROR]: 503 Service Temporarily Unavailable [cannot get img json]\n");
		return;
	}
}

sub send_Image {
	my ($self, $answer , $checksum) = @_;
	my $req_answer = POST 'http://playserver.co/index.php/Vote/ajax_submitpic/'.$self->{ServerUrl},[
		server_id => $self->{ServerID},
		captcha => $answer,
		gameid => $self->{GameID},
		checksum => $checksum
	];
	my $response_answer = $self->{ua}->request($req_answer);
	if ( $response_answer->is_success ) {
		my $response_answer_json = decode_json($response_answer->decoded_content);
		return $response_answer_json;
	} else {
		print("[ERROR]: 503 Service Temporarily Unavailable [cannot get answer json]\n");
		return;
	}
}


sub get_Url {
	my $self = shift;
	my ($serverid) = @_;
	my $mech = WWW::Mechanize->new();
	my $k;
	$mech->get( 'https://playserver.in.th/index.php/Server/'.$serverid);
	my @links = $mech->find_all_links(url_regex => qr/prokud\.*/);
	for my $link ( @links ) {
		$k = $link->url;
	}
	my @result = split '/', $k;
	return uri_encode($result[6]);
}

1;