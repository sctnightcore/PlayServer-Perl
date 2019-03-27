use FindBin qw( $RealBin );
use lib "$RealBin/Lib";
use Main;

Main::Loadlib();
Main::Start();

1;