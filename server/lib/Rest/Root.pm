package Rest::Root;

use strict;
use warnings;

use parent 'Plack::App::REST';

sub GET {

	return {
		test => 'test'
	};
}

1;