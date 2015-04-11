package Rest::HtmlVis::Logout;

use strict;
use warnings;

use parent qw( Rest::HtmlVis::Key );

my $style = '
body {
  background-color: #eee;
}

.info-panel {
  max-width: 330px;
  padding: 15px;
  margin: 0 auto;
}
.form-signin {
  max-width: 330px;
  padding: 15px;
  margin: 0 auto;
}
.form-signin .form-signin-heading,
.form-signin .checkbox {
  margin-bottom: 10px;
}
.form-signin .checkbox {
  font-weight: normal;
}
.form-signin .form-control {
  position: relative;
  height: auto;
  -webkit-box-sizing: border-box;
     -moz-box-sizing: border-box;
          box-sizing: border-box;
  padding: 10px;
  font-size: 16px;
}
.form-signin .form-control:focus {
  z-index: 2;
}
.form-signin input[type="email"] {
  margin-bottom: -1px;
  border-bottom-right-radius: 0;
  border-bottom-left-radius: 0;
}
.form-signin input[type="password"] {
  margin-bottom: 10px;
  border-top-left-radius: 0;
  border-top-right-radius: 0;
}
';

sub head {
	my ($self, $local) = @_;

	my $static = $self->baseurl;
	return '
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">

	<title>Logout</title>

	<!-- Custom styles for this template -->
	<style>
	'.$style.'
	</style>
	'
}

sub html {
	return '<div class="info-panel bg-success">Success</div>';
};

1;
=encoding utf-8

=head1 AUTHOR

Václav Dovrtěl E<lt>vaclav.dovrtel@gmail.comE<gt>
