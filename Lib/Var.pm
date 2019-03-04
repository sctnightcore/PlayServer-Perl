package Var;

use strict;
use warnings;

use Exporter;
our @ISA    = qw/ Exporter /;
our @EXPORT = qw/ @waitsend @success @fail/;

our (@waitsend,@success,@fail);
1;