package Plack::Middleware::CheckUserAccess;

use 5.006;
use strict;
use warnings FATAL => 'all';

use parent qw( Plack::Middleware );
use Plack::Util;
use Plack::Session;

use HTTP::Exception qw(3XX 4XX);
use MIME::Base64;

our $VERSION = '0.01'; # is set automagically with Milla

sub prepare_app {
	my $self = shift;

	$self->{login_url} = $self->{login_url} if exists $self->{login_url};
}

sub call {
	my($self, $env) = @_;

	my $session = Plack::Session->new($env);
	my $project = $env->{'rest.project'};
	my $sessionProjects = $session->get("projects")||{};

	if ($session->get("user_id") && exists $sessionProjects->{$project}){
		$env->{'rest.login'} = $session->get("user_id");
		### Run app
		my $res = $self->app->($env);
		return $res;
	};

	if ($env->{HTTP_ACCEPT} =~ /text\/html/ && $self->{login_url}){
		my $url = encode_base64($env->{REQUEST_URI});
		return [302, ['Content-Type', 'text/plain', 'Location', $self->{login_url}.'?goto='.$url]];
	}

	# Unauthorized
	return [403, ['Content-Type', 'text/plain']];
}

1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::CheckUserAccess - Check if user is set in session

=head1 SYNOPSIS

	use Plack::Middleware::CheckUserAccess;

	builder {
		enable 'CheckUserAccess';
		mount "/api" => sub { return [200, undef, {'link' => 'content'}] };
	};

=head1 DESCRIPTION

Check is use exists in session. Otherwise redirect to set url or return forbiden.

=head1 AUTHOR

Václav Dovrtěl E<lt>vaclav.dovrtel@gmail.comE<gt>

=head1 BUGS

Please report any bugs or feature requests to github repository.

=head1 ACKNOWLEDGEMENTS

Inspired by L<https://github.com/towhans/hochschober>

=head1 REPOSITORY

L<https://github.com/vasekd/Plack-Middleware-FormatOutput>

=head1 COPYRIGHT

Copyright 2015- Václav Dovrtěl

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut