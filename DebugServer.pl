use strict;
use IO::Socket::INET;
use Win32::Console::ANSI;

 
# auto-flush on socket
$| = 1;
 
# creating a listening socket
my $socket = new IO::Socket::INET (
    LocalHost => '0.0.0.0',
    LocalPort => '7777',
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
);
die "cannot create socket $!\n" unless $socket;
print "\e[1;37m===============================================\n";
print "Debug Perl-PlayServer Client by sctnightcore\n";
print "===============================================\e[0m\n";
while(1)
{
    # waiting for a new client connection
    my $client_socket = $socket->accept();
     # get information about a newly connected client
    my $client_address = $client_socket->peerhost();
    my $client_port = $client_socket->peerport();
     # read up to 1024 characters from the connected client
    my $data = "";
    $client_socket->recv($data, 1024);
    print "\e[1;37m$data\e[0m\n";
}
 
$socket->close();