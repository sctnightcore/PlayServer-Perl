package PlayServer;
use strict;
use JSON::MaybeXS;
use HTTP::Tiny;
use Data::Dumper;
use WWW::Mechanize;
use Win32::Console::ANSI;
use URI::Encode qw(uri_encode uri_decode);

sub new {
    my ($class, %args) = @_;
    my $self = {};
	$self->{ua} = HTTP::Tiny->new;
	$self->{game_ID} = $args{GameID};
	$self->{server_ID} = $args{ServerID};
	$self->{heads} = {'content-type' => 'application/x-www-form-urlencoded', 'Origin' => 'http://playserver.in.th', 'referer' => 'http://playserver.in.th/index.php/Vote/prokud/'.$self->{server_Url}};
	return bless $self, $class;
}

sub getserver_link {
	my ($self) = @_;
	my $mech = WWW::Mechanize->new();
	my $k;
	$mech->get( 'https://playserver.in.th/index.php/Server/'.$self->{server_ID});
	my @links = $mech->find_all_links(url_regex => qr/prokud\.*/);
	for my $link ( @links ) {
		my $url = $link->url;
		my @result = split '/', $url;
		$k = uri_encode($result[6]);
	}
	$self->{server_Url} = $k;
}

sub getimg_saveimg {
	my ($self) = @_;
	my $www = 'http://playserver.co/index.php/Vote/ajax_getpic/'.$self->{server_Url};
	my $res_getimg_saveimg = $self->{ua}->request('POST', $www);
	if ($res_getimg_saveimg->{success}) {
		if (defined($res_getimg_saveimg->{content})) {
			my $getimg_saveimg_json = decode_json($res_getimg_saveimg->{content});
			my $checksum = $getimg_saveimg_json->{'checksum'};
			$self->{ua}->mirror('http://playserver.co/index.php/VoteGetImage/'.$checksum, 'img/'.$checksum.'.png' );
			return $checksum if defined($checksum);
		} else {
			return;
		}
	} else {
		print "\e[1;41;1m[Cannot connect for Get Checksum]\e[0m\n";
		return;
	}
}

sub send_answer {
	my ($self, $answer, $checksum) = @_;
	my $www = 'http://playserver.co/index.php/Vote/ajax_submitpic/'.$self->{server_Url};
	my $form_data = { 'server_id' => $self->{server_ID}, 'captcha' => $answer, 'gameid' => $self->{game_ID}, 'checksum' => $checksum };
	my $heads = { headers => $self->{heads} };
	my $res_send_answer = $self->{ua}->post_form($www, $form_data, $heads);
	if ($res_send_answer->{success}) {
		if (defined($res_send_answer->{content})) {
			my $send_answer_json = decode_json($res_send_answer->{content});
			return $send_answer_json if defined($send_answer_json);
		} else {
			return;
		}
	} else {
		print "\e[1;41;1m[Cannot connect for Send Answer]\e[0m\n";
		return;
	}
}
1;