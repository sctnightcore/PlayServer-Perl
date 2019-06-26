package Var;
use strict;
use warnings;
use Exporter qw(import);
our @EXPORT = qw($success_count $fail_count $report_count $report_count_success $report_count_fail $interface $func_ac $func_ps $quit $gameid $serverid $config);

our $interface;
our $func_ac;
our $func_ps;
our $success_count;
our $fail_count;
our $report_count;
our $report_count_success;
our $report_count_fail;
our $quit;

#config
our $config;
#user info
our $gameid;
our $serverid;

1;