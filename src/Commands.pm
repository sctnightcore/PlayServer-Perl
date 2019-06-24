package Commands;
use Var qw($success_count $fail_count $report_count $report_count_success $report_count_fail $interface $func_ac $func_ps $quit);

sub Main {
    if ($_[0] eq 'sc') {
        my $msg;
        $msg .= "========================\n";
        $msg .= "[Score Voteing]\n";
        $msg .= "Success: $success_count\n";
        $msg .= "Fail: $fail_count\n";
        $msg .= "========================\n";
        $interface->writeoutput($msg);
    }

}
1;