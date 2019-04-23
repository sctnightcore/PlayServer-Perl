package PlayServer;
use strict;
use JSON::XS;
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
		$k = $link->url;
	}
	my @result = split '/', $k;
	$self->{server_Url} = uri_encode($result[6]);
}

sub getimg_saveimg {
	my ($self) = @_;
	my $www = 'http://playserver.co/index.php/Vote/ajax_getpic/'.$self->{server_Url};
	my $res_get_img = $self->{ua}->request('POST', $www);
	if ($res_get_img->{success}) {
		return if ($res_get_img->{content} eq '');
		my $getimg_saveimg_json = decode_json($res_get_img->{content});
		my $checksum = $getimg_saveimg_json->{'checksum'};
		my $res_save_img = $self->{ua}->mirror("http://playserver.co/index.php/VoteGetImage/$checksum", "img//$checksum.png" );
		if ($res_save_img->{success}) {
			return $checksum;
		}
	} else {
		print "\e[1;41;1m[Cannot connect for Get Checksum]\e[0m\n";
		return;
	}
}

sub get_point {
	my ($self) = @_;
	my $www = 'https://playserver.in.th/index.php/Server/ajax_checkpoint/'.$self->{server_ID};
	my $form_data = { gameid => $self->{game_ID} };
	my $res_get_point = $self->{ua}->post_form($www, $form_data);
	if ($res_get_point->{success}) {
		return if ($res_get_point->{content} eq '');
		my $getpoint_json = decode_json($res_get_point->{content});
		my $point = $getpoint_json->{'point'};
		return $point if defined($point);
	} else {
		print "\e[1;41;1m[Cannot connect for Get Point]\e[0m\n";
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
		return if ($res_send_answer->{content} eq '');
		my $send_answer_json = decode_json($res_send_answer->{content});
		return $send_answer_json if defined($send_answer_json);
	} else {
		print "\e[1;41;1m[Cannot connect for Send Answer]\e[0m\n";
		return;
	}
}
1;