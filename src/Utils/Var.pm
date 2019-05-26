package Utils::Var;
use strict;
use warnings;
use Exporter;
our @ISA    = qw/ Exporter /;
our @EXPORT = qw/ $success_count $fail_count $report_count $report_count_success $report_count_fail/;

our $success_count;
our $fail_count;
our $report_count;
our $report_count_success;
our $report_count_fail;
1;