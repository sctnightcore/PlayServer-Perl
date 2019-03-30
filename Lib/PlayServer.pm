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
	return bless $self, $class;
}

sub getimg_saveimg {
	my ($self) = @_;
	my $res_getimg_saveimg = $self->{ua}->request('POST', 'http://playserver.co/index.php/Vote/ajax_getpic/'.$self->{server_Url});
	if ($res_getimg_saveimg->{success}) {
		my $getimg_saveimg_json = decode_json($res_getimg_saveimg->{content});
		$self->{checksum} = $getimg_saveimg_json->{'checksum'};
		print "[GetChecksum]: $self->{checksum}\n";
		$self->{ua}->mirror('http://playserver.co/index.php/VoteGetImage/'.$self->{checksum}, 'img/'.$self->{checksum}.'.png' );
		print "[DownloadCheckSum]: $self->{checksum}\n";
		return ($self->{checksum},$getimg_saveimg_json->{'checksum'});
	} else {
		return 1;
	}
}

sub send_answer {
	my ($self, $answer) = @_;
	my $www_sendanswer = "http://playserver.co/index.php/Vote/ajax_submitpic/$self->{server_Url}";
	my $res_send_answer = $self->{ua}->request('POST', $www_sendanswer, {
		content => "server_id=$self->{server_ID}&captcha=$answer&gameid=$self->{game_ID}&checksum=$self->{checksum}",,
		headers => { 
	  		'content-type' => 'application/x-www-form-urlencoded',
	  		'referer' => "http://playserver.in.th/index.php/Vote/prokud/$self->{server_Url}"}
	});
	if ($res_send_answer->{success}) {
		my $send_answer_json = decode_json($res_send_answer->{content});
		if ($send_answer_json->{'success'} eq '1') {
			print("[+] | \e[0;32m[Success]\e[0m | $self->{checksum}.png | $answer\n");
		} else {
			print("[-] | \e[0;31m[Fail]\e[0m | $self->{checksum}.png | $answer\n");
		}
	}
}
1;