package Auth::Token;

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

	use Data::Dumper;
	print STDERR "ENV: ".Dumper($env);

	### Set token
	return {
		token => 'xyz'
	};
}

1;