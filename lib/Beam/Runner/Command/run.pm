package Beam::Runner::Command::run;
our $VERSION = '0.001';
# ABSTRACT: Run the given service with the given arguments

=head1 SYNOPSIS

    beam run <container> <service> [<args...>]

=head1 DESCRIPTION

Run a service from the given container, passing in any arguments.

=head1 SEE ALSO

L<beam>, L<Beam::Runner::Command>, L<Beam::Runner>

=cut

use strict;
use warnings;
use Beam::Wire;
use Path::Tiny qw( path );
use Scalar::Util qw( blessed );

# File extensions to try to find, starting with no extension (which is
# to say the extension is given by the user's input)
my @EXTS = ( "", qw( .yml .yaml .json .xml .pl ) );

sub run {
    my ( $class, $container, $service_name, @args ) = @_;
    my $path;
    if ( path( $container )->is_file ) {
        $path = path( $container );
    }
    else {
        my @dirs = ( "." );
        if ( $ENV{BEAM_PATH} ) {
            push @dirs, split /:/, $ENV{BEAM_PATH};
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
            $container, join( ":", @dirs )
            unless $path;
    }

    my $wire = Beam::Wire->new(
        file => $path,
    );

    my $service = eval { $wire->get( $service_name ) };
    if ( $@ ) {
        if ( blessed $@ && $@->isa( 'Beam::Wire::Exception::NotFound' ) ) {
            die sprintf qq{Could not find service "%s" in container "%s"\n},
                $service_name, $path;
        }
        die $@;
    }

    return $service->run( @args );
}

1;

