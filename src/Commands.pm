package Commands;
use Var;

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