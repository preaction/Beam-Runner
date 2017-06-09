package Beam::Runner;
our $VERSION = '0.011';
# ABSTRACT: Configure, list, document, and execute runnable task objects

=head1 SYNOPSIS

    beam run <container> <task> [<args...>]
    beam list
    beam list <container>
    beam help <container> <task>
    beam help

=head1 DESCRIPTION

This distribution is an execution and organization system for runnable
objects (tasks). This allows you to prepare a list of runnable tasks in
configuration files and then execute them. This also allows easy
discovery of configuration files and objects, and allows you to document
your objects for your users.

=head2 Configuration Files

The configuration file is a L<Beam::Wire> container file that describes
objects. Some of these objects are marked as executable tasks by
consuming the L<Beam::Runnable> role.

The container file can have a special entry called C<$summary> which
has a short summary that will be displayed when using the C<beam list>
command.

Here's an example container file that has a summary, configures
a L<DBIx::Class> schema (using the schema class for CPAN Testers:
L<CPAN::Testers::Schema>), and configures a runnable task called
C<to_metabase> located in the class
C<CPAN::Testers::Backend::Migrate::ToMetabase>:

    # migrate.yml
    $summary: Migrate data between databases

    _schema:
        $class: CPAN::Testers::Schema
        $method: connect_from_config

    to_metabase:
        $class: CPAN::Testers::Backend::Migrate::ToMetabase
        schema:
            $ref: _schema

For more information about container files, see L<the Beam::Wire
documentation|Beam::Wire>.

=head2 Tasks

A task is an object configured in the container file that consumes the
L<Beam::Runnable> role. This role requires only a C<run()> method be
implemented in the class.

Task modules are expected to have documentation that will be displayed
by the C<beam list> and C<beam help> commands. The C<beam list> command
will display the C<NAME> section of the documentation, and the C<beam
help> command will display the C<NAME>, C<SYNOPSIS>, C<DESCRIPTION>,
C<ARGUMENTS>, C<OPTIONS>, C<ENVIRONMENT>, and C<SEE ALSO> sections of
the documentation.

Task modules can compose additional roles to easily add more features,
like adding a timeout with L<Beam::Runnable::Timeout::Alarm>.

=head1 SEE ALSO

L<beam>, L<Beam::Runnable>, L<Beam::Wire>

=cut

use strict;
use warnings;



1;

