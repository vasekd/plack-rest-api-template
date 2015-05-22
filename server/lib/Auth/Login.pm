package Auth::Login;

use strict;
use warnings;

use parent 'Plack::App::REST';

use Plack::Util::Accessor qw(auth);
use Plack::Session;
use MIME::Base64;

use HTTP::Exception qw(3XX);

sub new {
	my ($class, $auth) = @_;
	my $self = $class->SUPER::new();
	$self->{auth} = $auth;
	return $self;
}

sub GET {
	my ($self, $env) = @_;
	my $goto = GetGoto($env);

	###  Check if user is already loged in
	my $session = Plack::Session->new($env);
	if ($session->get("user_id")){
		# Check number of requests
		my $req_number = $session->get('req_number')||0;
		if ($req_number >= 5){
			$session->set('req_number', 0);
			HTTP::Exception::400->throw(message=>'Redirection loop.');
		}else{
			$session->set('req_number', ++$req_number);
		}

		HTTP::Exception::302->throw(location=>$goto) if $goto;
		return { login => 'login' };
	}

	### Return login form
	return { login => undef };
}

sub POST {
	my ($self, $env, $params, $data) = @_;

	my $session = Plack::Session->new($env);
	my $goto = GetGoto($env);

	if (
		defined $data->{email} 
		&& defined $data->{password}
		&& (my $projects = $self->auth->checkUser($env, $data->{email}, $data->{password}))
	){
		# Login success
		SetUser($session, $env, $data->{email}, $projects);
		if ($goto){
			HTTP::Exception::302->throw(location=>$goto);
		}
		return { login => 'success' };
	}

	# Login failed
	return { login => 'failed' };	
}

sub GetGoto {
	my ($env) = @_;
	my $req = Plack::Request->new($env);
	my $query = $req->query_parameters;
	my $goto = decode_base64($query->{goto}) if exists $query->{goto};
	return $goto;
}

sub SetUser {
	my ($session, $env, $login, $projects) = @_;

	$env->{'psgix.logger'}->({level => 'debug', message => 'Loged: '.$login});
	$session->set("user_id", $login);
	$session->set("projects", $projects);
}

1;