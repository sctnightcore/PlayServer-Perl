use strict;
use warnings;
use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use pipe;

pipe::server();
1;
