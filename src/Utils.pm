package Utils;
use strict;
use warnings;
use Var;

sub title_count {
	my $success = defined($success_count) ? $success_count : 0;
	my $fail = defined($fail_count) ? $fail_count : 0;
	my $report = defined($report_count) ? $report_count : 0;
	my $report_success = defined($report_count_success) ? $report_count_success : 0;
	my $report_fail = defined($report_count_fail) ? $report_count_fail : 0;
    $interface->title("[ GameID: $gameid | ServerID: $serverid ]-[ Success: $success | Fail: $fail ]");
}


sub Logic_Start {

}
1;