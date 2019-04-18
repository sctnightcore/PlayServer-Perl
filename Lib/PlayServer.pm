package PlayServer;
use strict;
use JSON::XS;
use HTTP::Tiny;
use Data::Dumper;
use Win32::Console::ANSI;

sub new {
    my ($class, %args) = @_;
    my $self = {};
	$self->{ua} = HTTP::Tiny->new;
	$self->{json} = JSON::XS->new->allow_nonref;
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
		my $getimg_saveimg_json = $self->{json}->decode($res_getimg_saveimg->{content});
		my $checksum = $getimg_saveimg_json->{'checksum'};
		$self->{ua}->mirror('http://playserver.co/index.php/VoteGetImage/'.$checksum, 'img/'.$checksum.'.png' );
		return $checksum;
	} else {
		print "\e[1;41;1m[Cannot Get Checksum from PlayServer.in.th]\e[0m\n";
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
		my $send_answer_json = $self->{json}->decode($res_send_answer->{content});
		return $send_answer_json;
	} else {
		print "\e[1;41;1m[Cannot Send Answer to PlayServer.in.th]\e[0m\n";
		return;
	}
}
1;