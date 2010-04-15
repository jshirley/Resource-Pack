package Resource::Pack::File;
use Moose;
use MooseX::Types::Path::Class qw(File Dir);

use File::Copy::Recursive qw(fcopy);

with 'Resource::Pack::Installable',
     'Bread::Board::Service',
     'Bread::Board::Service::WithDependencies';

has file => (
    is      => 'ro',
    isa     => File,
    coerce  => 1,
    lazy    => 1,
    default => sub { Path::Class::File->new(shift->name) },
);

sub get { shift->file }

has install_from_dir => (
    is         => 'rw',
    isa        => Dir,
    coerce     => 1,
    init_arg   => 'install_from',
    predicate  => 'has_install_from_dir',
    default    => sub {
        my $self = shift;
        if ($self->has_parent && $self->parent->has_install_from_dir) {
            return $self->parent->install_from_dir;
        }
        else {
            confess "install_from is required for File resources without a container";
        }
    },
);

has install_as => (
    is      => 'rw',
    isa     => File,
    coerce  => 1,
    lazy    => 1,
    default => sub { shift->file },
);

sub install {
    my $self = shift;
    my $from = $self->install_from_dir->file($self->file)->stringify;
    my $to   = $self->install_to_dir->file($self->install_as)->stringify;
    fcopy($from, $to) or die "Couldn't copy $from to $to: $!";
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
