package Beam::Runner::Util;
our $VERSION = '0.007';
# ABSTRACT: Utilities for Beam::Runner command classes

=head1 SYNOPSIS

    use Beam::Runner::Util qw( find_container_path );

    my $path = find_container_path( $container_name );

=head1 DESCRIPTION

This module has some shared utility functions for creating
L<Beam::Runner::Command> classes.

=head1 SEE ALSO

L<Beam::Runner>, L<beam>, L<Exporter>

=cut

use strict;
use warnings;
use Exporter 'import';
use Path::Tiny qw( path );

our @EXPORT_OK = qw( find_container_path );

# File extensions to try to find, starting with no extension (which is
# to say the extension is given by the user's input)
our @EXTS = ( "", qw( .yml .yaml .json .xml .pl ) );

# The "BEAM_PATH" separator value. Windows uses ';' to separate
# PATH-like variables, everything else uses ':'
our $PATHS_SEP = $^O eq 'MSWin32' ? ';' : ':';

=sub find_container_path

    my $path = find_container_path( $container_name );

Find the path to the given container. If the given container is already
an absolute path, it is simply returned. Otherwise, the container is
searched for in the directories defined by the C<BEAM_PATH> environment
variable.

If the container cannot be found, throws an exception with a user-friendly
error message.

=cut

sub find_container_path {
    my ( $container ) = @_;
    my $path;
    if ( path( $container )->is_file ) {
        return path( $container );
    }

    my @dirs = ( "." );
    if ( $ENV{BEAM_PATH} ) {
        push @dirs, split /$PATHS_SEP/, $ENV{BEAM_PATH};
    }

    DIR: for my $dir ( @dirs ) {
        my $d = path( $dir );
        for my $ext ( @EXTS ) {
            my $f = $d->child( $container . $ext );
            if ( $f->exists ) {
                $path = $f;
                last DIR;
            }
        }
    }

    die sprintf qq{Could not find container "%s" in directories: %s\n},
        $container, join( $PATHS_SEP, @dirs )
        unless $path;

    return $path;
}

1;
