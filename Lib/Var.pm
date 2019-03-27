package Var;

use strict;
use warnings;

use Exporter;
our @ISA    = qw/ Exporter /;
our @EXPORT = qw/$success $fail $waitsend/;

our $success = 0;
our $fail = 0;
our $waitsend = 0;
1;