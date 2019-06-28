package YAML::LibYAML::API::XS;
use strict;
use warnings;

our $VERSION = '0.000'; # VERSION

use XSLoader;
XSLoader::load('YAML::LibYAML::API::XS', $VERSION);

sub new {
    my ($class, %args) = @_;
    my $self = bless {
    }, $class;
    return $self;
}

sub set_parse_callback {
    my ($self, $code) = @_;
    $self->{parse_callback} = $code;
}

sub parse_events {
    parse_string_events(@_);
}

1;

__END__

=pod

=head1 NAME

YAML::LibYAML::API::XS - Wrapper around the C libyaml library

=cut
