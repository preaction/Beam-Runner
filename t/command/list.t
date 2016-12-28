
=head1 DESCRIPTION

This file tests the L<Beam::Runner::Command::list> class to ensure it
lists all the container files in C<BEAM_PATH>, and lists all the runnable
services in a particular container.

This file uses the C<t/lib/Local/Runnable.pm> file as a runnable object,
and C<t/share/container.yml> as the L<Beam::Wire> container.

=head1 SEE ALSO

L<Beam::Runner::Command::list>

=cut

use strict;
use warnings;
use Test::More;
use Test::Lib;
use Test::Fatal;
use Local::Runnable;
use FindBin ();
use Path::Tiny qw( path );
use Capture::Tiny qw( capture );
use Beam::Runner::Command::list;

my $SHARE_DIR = path( $FindBin::Bin, '..', 'share' );
my $class = 'Beam::Runner::Command::list';

subtest 'list all containers' => sub {
    local $ENV{BEAM_PATH} = "$SHARE_DIR";
    my ( $stdout, $stderr, $exit ) = capture {
        $class->run;
    };
    ok !$stderr, 'nothing on stderr';
    is $exit, 0, 'exit 0';
    is $stdout, "container\n", 'containers listed on stdout';
};

subtest 'list runnable services in container' => sub {
    my @svcs = qw( alias extends fail success );
    my $expect_out = join( "\n", @svcs )."\n";

    local $ENV{BEAM_PATH} = "$SHARE_DIR";
    my ( $stdout, $stderr, $exit ) = capture {
        $class->run( 'container' );
    };
    ok !$stderr, 'nothing on stderr';
    is $exit, 0, 'exit 0';
    is $stdout, $expect_out, 'runnable services listed on stdout';

    subtest 'container with full path' => sub {
        my ( $stdout, $stderr, $exit ) = capture {
            $class->run( $SHARE_DIR->child( 'container.yml' )."" );
        };
        ok !$stderr, 'nothing on stderr';
        is $exit, 0, 'exit 0';
        is $stdout, $expect_out, 'runnable services listed on stdout';
    };
};

subtest 'errors' => sub {
    subtest '$BEAM_PATH is not set' => sub {
        local $ENV{BEAM_PATH} = undef;
        is exception { $class->run }, "Cannot list containers: BEAM_PATH environment variable not set\n";
    };
};

done_testing;
