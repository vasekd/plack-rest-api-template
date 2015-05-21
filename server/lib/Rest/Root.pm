package Rest::Root;

use strict;
use warnings;

use parent 'Plack::App::RESTMy';

sub GET {
	my ($self, $env) = @_;

	### Get all links
	my $links;
	my $project = $env->{'rest.project'};
	my $map = $self->const->get("RestMap");
	my $prefix = $self->const->get("ApiPrefix");
	my $version = $self->const->get("ApiVersion");

	foreach my $resource (sort keys %{$map->{$version}}) {
		push @$links, {
			href => sprintf('/%s%s/%s%s', $project, $prefix, $version, $resource),
			title => $resource,
			rel => $map->{$version}{$resource},
		}
	}

	### Get all auth links
	my $mapAuth = $self->const->get("AuthMap");
	my $prefixAuth = $self->const->get("AuthPrefix");

	foreach my $resource (sort keys %{$mapAuth}) {
		push @$links, {
			href => sprintf('%s%s', $prefixAuth, $resource),
			title => $resource,
			rel => $mapAuth->{$resource},
		}
	}

	return {
		links => $links,
		ApiVersion => $version,
		user => $env->{'rest.login'},
		project => $project
	};
}

1;