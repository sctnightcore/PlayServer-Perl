package PlayServer;
use strict;
use JSON;
use HTTP::Tiny;
use Data::Dumper;
use Win32::Console::ANSI;

sub new {
    my ($class, %args) = @_;
    my $self = {};
	$self->{ua} = HTTP::Tiny->new;
	$self->{server_Url} = $args{Server_Url};
	$self->{game_ID} = $args{GameID};
	$self->{server_ID} = $args{ServerID};
	$self->{heads} = {
		'content-type' => 'application/x-www-form-urlencoded',
		'Origin' => 'http://playserver.in.th',
		'referer' => 'http://playserver.in.th/index.php/Vote/prokud/'.$self->{server_Url}
	};
	return bless $self, $class;
}

sub getimg_saveimg {
	my ($self) = @_;
	my $res_getimg_saveimg = $self->{ua}->request('POST', 'http://playserver.co/index.php/Vote/ajax_getpic/'.$self->{server_Url});
	if ($res_getimg_saveimg->{success}) {
		my $getimg_saveimg_json = decode_json($res_getimg_saveimg->{content});
		my $checksum = $getimg_saveimg_json->{'checksum'};
		$self->{ua}->mirror('http://playserver.co/index.php/VoteGetImage/'.$checksum, 'img/'.$checksum.'.png' );
		return $checksum;
	} else {
		return;
	}
}

sub send_answer {
	my ($self, $answer, $checksum) = @_;
	my $res_send_answer = $self->{ua}->post_form('http://playserver.co/index.php/Vote/ajax_submitpic/'.$self->{server_Url},{
		'server_id' => $self->{server_ID},
		'captcha' => $answer,
		'gameid' => $self->{game_ID},
		'checksum' => $checksum
	},{headers => $self->{heads}});
	if ($res_send_answer->{success}) {
		my $send_answer_json = decode_json($res_send_answer->{content});
		return $send_answer_json;
	} else {
		return;
	}
}
1;