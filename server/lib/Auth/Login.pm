package Auth::Login;

use strict;
use warnings;

use parent 'Plack::App::REST';

use Plack::Util::Accessor qw(auth);

sub new {
	my ($class, $auth) = @_;
	my $self = $class->SUPER::new();
	$self->{auth} = $auth;
	return $self;
}

sub GET {
	### Return login form
	return { login => undef };
}

sub POST {
	my ($self, $env, $params, $data) = @_;

	if (
		defined $data->{email} 
		&& defined $data->{password}
		&& $self->auth->checkUser($env, $data->{email}, $data->{password})
	){
		# Login success
		SetUser($env, $data->{email});
		return { login => 'success' };	
	}

	# Login failed
	return { login => 'failed' };	
}

sub SetUser {
	my ($env, $login) = @_;
	$env->{'psgix.logger'}->({level => 'debug', message => 'Loged: '.$login});
	$env->{"psgix.session"}{user_id} = $login;
}

1;