package SocketClient;
use strict;
use IO::Socket::INET;
$| = 1;

sub new {
    my ($class, %args) = @_;
    my $self = {};
	return bless $self, $class;
}


sub sendSocket {
	my ($self, $msg) = @_;
	# create a connecting socket
	my $socket = new IO::Socket::INET (
	    PeerHost => '127.0.0.1',
	    PeerPort => '7777',
	    Proto => 'tcp'
	);
	die "cannot connect to the server $!\n" unless $socket;
	$socket->send($msg);
	$socket->close();
}

1;