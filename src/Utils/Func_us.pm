package Utils::Func_us;
use strict;
use Win32::Console;

sub new {
	my ($class, %args) = @_;
	my $self = {};
	$self->{cs} = Win32::Console->new();
	return bless $self, $class;
}

sub update_Title {
	my ($self, $msg) = @_;
	$self->{cs}->Title($msg);
}


1;