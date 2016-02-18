use strict;
use warnings;

use App::Cmd::Tester;
use Data::Dumper;
use Footprintless;
use File::Basename;
use File::Spec;
use Test::More tests => 3;

BEGIN {use_ok('Footprintless::App')}

eval {
    require Getopt::Long;
    Getopt::Long::Configure('pass_through', 'bundling');
    my $level = 'error';
    Getopt::Long::GetOptions(
        'log:s' => \$level
    );

    require Log::Any::Adapter;
    Log::Any::Adapter->set('+Footprintless::Test::Log::Any::Adapter::Handle', 
        handle => \*STDOUT,
        log_level => Log::Any::Adapter::Util::numeric_level($level));
};

my $logger = Log::Any->get_logger();
$logger->trace("All logging sent to stderr to avoid conflict with output");

my $test_dir = dirname( File::Spec->rel2abs( $0 ) );

$ENV{FPL_CONFIG_DIRS} = File::Spec->catdir($test_dir, 'config', 'entities');
$ENV{FPL_CONFIG_PROPS} = File::Spec->catfile($test_dir, 'config', 'credentials.pl');

is(test_app('Footprintless::App' => 
    [
        'config',
        'dev.foo.tomcat.overlay.os',
        '--format',
        'dumper0' 
    ])->stdout(), 
    "\$VAR1 = 'linux';", 'dev.foo.tomcat.overlay.os = linux');
is(test_app('Footprintless::App' => 
    [
        'config', 
        'dev.foo.logs', 
        '--format', 
        'json2' 
    ])->stdout(), 
   '{"catalina":"/opt/pastdev/foo-tomcat/logs/catalina.out"}',
   'json dev.piab = {...}');