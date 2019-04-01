package pipe;
use strict;
use warnings;
use Win32::Pipe;



sub server {
	my $jobPipe = new Win32::Pipe('jobPipe') || die "Can't Create Named Pipe 'jobPipe'\n";
	print "[PlayServer-Perl]-[LogChecksum-LogAnswer]\n";
	while (1) {
		if (!$jobPipe->Connect()) {
		 	print "jobPipe connect failed\n";
		 	last;
		}
		my $line = '';
		while (my $buf = $jobPipe->Read()) {
			$line .= $buf;
		}
		print "$line\n";
	}
	$jobPipe->Close();	
}


sub client {
	my ($checksum, $answer, $count) = @_;
	my $jobPipe = new Win32::Pipe("\\\\.\\PIPE\\jobPipe") or die "could not open jobPipe\n";
	$jobPipe->Write("[$count] $checksum | $answer\n");
	$jobPipe->Close();
}

1;