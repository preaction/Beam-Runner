package Beam::Runner;
our $VERSION = '0.003';
# ABSTRACT: Execute runnable objects from Beam::Wire containers

=head1 SYNOPSIS

    beam run <container> <service> [<args...>]
    beam list
    beam list <container>
    beam help <container> <service>
    beam help

=head1 DESCRIPTION

This distribution is an execution and organization system for
L<Beam::Wire> containers. This allows you to prepare executable objects
in configuration files and then execute them. This also allows easy
discovery of container files and objects, and allows you to document
your objects for your users.

=head1 SEE ALSO

L<beam>, L<Beam::Runnable>, L<Beam::Wire>

=cut

use strict;
use warnings;



1;

