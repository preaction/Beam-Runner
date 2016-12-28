package Beam::Runner::Command::list;
our $VERSION = '0.003';
# ABSTRACT: List the available containers and services

=head1 SYNOPSIS

    beam list
    beam list <container>

=head1 DESCRIPTION

List the available containers found in the directories defined in
C<BEAM_PATH>, or list the runnable services found in the given
container.

When listing services, this command must load every single class
referenced in the container, but it will not instanciate any object.

=head1 SEE ALSO

L<beam>, L<Beam::Runner::Command>, L<Beam::Runner>

=cut

use strict;
use warnings;
use List::Util qw( any );
use Path::Tiny qw( path );
use Module::Runtime qw( use_module );
use Beam::Wire;
use Beam::Runner::Util qw( find_container_path );

# The extensions to remove to show the container's name
my @EXTS = grep { $_ } @Beam::Runner::Util::EXTS;
# A regex to use to remove the container's name
my $EXT_RE = qr/(?:@{[ join '|', @EXTS ]})$/;

=method run

    my $exit = $class->run;
    my $exit = $class->run( $container );

Print the list of containers to C<STDOUT>, or, if C<$container> is given,
print the list of runnable services. A runnable service is an object
that consumes the L<Beam::Runnable> role.

=cut

sub run {
    my ( $class, $container ) = @_;

    if ( !$container ) {
        return $class->_list_containers;
    }
    return $class->_list_services( $container );
}

#=sub _list_containers
#
#   my $exit = $class->_list_containers
#
# Print all the containers found in the BEAM_PATH to STDOUT
#
#=cut

sub _list_containers {
    my ( $class ) = @_;
    die "Cannot list containers: BEAM_PATH environment variable not set\n"
        unless $ENV{BEAM_PATH};
    for my $dir ( split /:/, $ENV{BEAM_PATH} ) {
        my $p = path( $dir );
        my $i = $p->iterator( { recurse => 1, follow_symlinks => 1 } );
        while ( my $file = $i->() ) {
            next unless $file->is_file;
            next unless $file =~ $EXT_RE;
            my $name = $file->relative( $p );
            $name =~ s/$EXT_RE//;
            print "$name\n";
        }
    }
    return 0;
}

#=sub _list_services
#
#   my $exit = $class->_list_services( $container );
#
# Print all the runnable services found in the container to STDOUT
#
#=cut

sub _list_services {
    my ( $class, $container ) = @_;
    my $path = find_container_path( $container );
    my $wire = Beam::Wire->new(
        file => $path,
    );

    my $config = $wire->config;
    my @services;
    for my $name ( keys %$config ) {
        push @services, _list_service( $wire, $name, $config->{$name} );
    }
    print join( "\n", sort @services ), "\n";
    return 0;
}

#=sub _list_service
#
#   my $service_info = _list_service( $wire, $name, $config );
#
# If the given service is a runnable service, return the information
# about it ready to be printed to STDOUT. $wire is a Beam::Wire object,
# $name is the name of the service, $config is the service's
# configuration hash
#
#=cut

sub _list_service {
    my ( $wire, $name, $svc ) = @_;

    # If it doesn't look like a service, we don't care
    return unless $wire->is_meta( $svc, 1 );

    # Service hashes should be loaded and printed
    my %meta = $wire->get_meta_names;

    # Services that are just references to other services should still
    # be available under their referenced name
    my %svc = %{ $wire->normalize_config( $svc ) };
    if ( $svc{ ref } ) {
        my $ref_svc = $wire->get_config( $svc{ ref } );
        return _list_service( $wire, $name, $ref_svc );
    }

    # Services that extend other services must be resolved to find their
    # class and roles
    my %merged = $wire->merge_config( %svc );
    #; use Data::Dumper;
    #; print "$name merged: " . Dumper \%merged;
    my $class = $merged{ class };
    my @roles = @{ $merged{ with } || [] };

    # Can we determine this object is runnable without loading anything?
    if ( grep { $_ eq 'Beam::Runnable' } @roles ) {
        return _get_service_info( $name, $class );
    }

    if ( eval { any {; use_module( $_ )->DOES( 'Beam::Runnable' ) } $class, @roles } ) {
        return _get_service_info( $name, $class );
    }

    return;
}

#=sub _get_service_info( $name, $class )
#
#   my $info_str = _get_service_info( $name, $class );
#
# Get the information about the given service. Presently returns the
# name, but in the future will look in the class for some documentation
# about the service.
#
#=cut

sub _get_service_info {
    my ( $name, $class ) = @_;
    return $name;
}

1;


