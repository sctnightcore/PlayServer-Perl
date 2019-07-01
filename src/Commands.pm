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
    } elsif ( $_[0] eq 'exit') {
        $interface->writeoutput("Press ENTER to exit.\n");
        <STDIN>;
        exit;
    } else {
        $interface->writeoutput("UNKNOWN COMMAND: $_[0]\n");
    }

}
1;