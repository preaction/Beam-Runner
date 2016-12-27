package Beam::Runner::Command;
our $VERSION = '0.001';
# ABSTRACT: Main command handler delegating to individual commands

=head1 SYNOPSIS

    exit Beam::Runner::Command->run( $cmd => @args );

=head1 DESCRIPTION

This is the entry point for the L<beam> command which loads and
runs the specific C<Beam::Runner::Command> class.

=head1 SEE ALSO

The L<Beam::Runner> commands: L<Beam::Runner::Command::run>,
L<Beam::Runner::Command::list>, L<Beam::Runner::Command::help>

=cut

use strict;
use warnings;
use Module::Runtime qw( use_module compose_module_name );

sub run {
    my ( $class, $cmd, @args ) = @_;
    my $cmd_class = compose_module_name( 'Beam::Runner::Command', $cmd );
    return use_module( $cmd_class )->run( @args );
}

1;

