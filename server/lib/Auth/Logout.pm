package Auth::Logout;

use strict;
use warnings;

use parent 'Plack::App::REST';

sub new {
	my ($class, $auth) = @_;
	my $self = $class->SUPER::new();
	$self->{auth} = $auth;
	return $self;
}

sub GET {
	my ($self, $env) = @_;
	UnSetUser($env);
	return {
		logout => 1
	};
}

sub UnSetUser {
	my ($env) = @_;

	my $session = Plack::Session->new($env);
	$session->remove("user_id");
}

1;