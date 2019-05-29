package Utils::Func_us;
use strict;
use Utils::Var qw( $success_count $fail_count $report_count $report_count_success $report_count_fail );
use Win32::Console;

sub new {
	my ($class, %args) = @_;
	my $self = {};
	$self->{debug} = $args{Debug};
	$self->{cs} = Win32::Console->new();
	return bless $self, $class;
}

sub update_Title {
	my ($self, $msg) = @_;
	if ( $self->{debug} == 1 ) {
		printf('[DEBUG_US]->[%s:%s]', 'UPDATE_TITLE', $msg);
	}
	$self->{cs}->Title($msg);
}

sub update_score {
	my ($self) = @_;
	my $success = defined($success_count) ? $success_count : 0;
	my $fail = defined($fail_count) ? $fail_count : 0;
	my $report = defined($report_count) ? $report_count : 0;
	my $report_success = defined($report_count_success) ? $report_count_success : 0;
	my $report_fail = defined($report_count_fail) ? $report_count_fail : 0;
	my $title = sprintf("[ Success: %3s | Fail: %3s ]-----[ By SCTNIGHTCORE ]", $success, $fail);
	if ( $self->{debug} == 1 ) {
		printf('[DEBUG_US]->[%s:%s/%s]', 'UPDATE_SCORE', $success, $fail);
	}
	$self->{cs}->Title($title);
}
1;