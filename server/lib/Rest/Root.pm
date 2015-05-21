package Rest::Root;

use strict;
use warnings;

use parent 'Plack::App::RESTMy';

sub GET {

	return {
		test => 'test'
	};
}

1;