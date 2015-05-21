package Plack::App::RESTMy;

use strict;
use warnings;

use parent 'Plack::App::REST';

use Plack::Util::Accessor qw(const);

sub new {
	my ($class, $const) = @_;
	my $self = $class->SUPER::new();

	$self->{const} = $const;

	return $self;
}

sub structToLinksByType {
	my ($self, $rel, $base, $data) = @_;

	my @links;
	foreach my $type (sort keys %$data) {
		foreach my $key (sort keys %{$data->{$type}}){
			my $val = $data->{$type}{$key};
			push @links, $self->idToLink($rel, $base.'/'.$type, $val->{id}, $val->{name});
		}
	}

	return \@links;
}

sub structToLinks {
	my ($self, $rel, $base, $data) = @_;

	my @links;
	foreach my $key (sort keys %$data) {
		push @links, $self->idToLink($rel, $base, $data->{$key}{id}, $data->{$key}{name});
	}

	return \@links;
}

sub idToLink {
	my ($self, $rel, $base, $id, $name) = @_;

	return {
		href => $base.'/'.$id,
		title => ($name||$id),
		rel => $rel
	}
}

1;