package File;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = {};
    $self->{path} = $args{Path};
    return bless $self, $class;
}

sub file_remove {
	my ($self,$checksum) = @_;
	my $file = "$self->{path}/$checksum.png";
	my $removed = unlink($file);
}

sub clear_oldchecksum {
	my ($self) = @_;
	unlink glob "$self->{path}/*.png";
}
1;