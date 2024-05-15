#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use IPC::Cmd qw/can_run/;

plan tests => 2;

BEGIN {
    use_ok( 'PDL::Bart' ) || print "Bail out!\n";
    ok(can_run('bart'));
}

diag( "Testing PDL::Bart $PDL::Bart::VERSION, Perl $], $^X" );
