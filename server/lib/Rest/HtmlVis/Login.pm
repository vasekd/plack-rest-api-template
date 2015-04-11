package Rest::HtmlVis::Login;

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

	<title>Login</title>

	<!-- Custom styles for this template -->
	<style>
	'.$style.'
	</style>
	'
}

sub html {
  my ($self) = @_;

  my $struct = $self->getStruct;

  my $success = '';
  if ($struct && $struct eq 'success'){
    $success = '<div class="info-panel bg-success">Success</div>';
  }elsif ($struct && $struct eq 'failed'){
    $success = '<div class="info-panel bg-danger">Wrong login name or password</div>';
  }

	return '
    <div class="container">
      <form class="form-signin" method="POST" enctype="application/x-www-form-urlencoded">
        '.$success.'
        <h2 class="form-signin-heading">Please sign in</h2>
        <label for="email" class="sr-only">Email address</label>
        <input type="email" name="email" id="email" class="form-control" placeholder="Email address" required autofocus>
        <label for="password" class="sr-only">Password</label>
        <input type="password" name="password" id="password" class="form-control" placeholder="Password" required>
        <div class="checkbox">
          <label>
            <input type="checkbox" name="remember-me" value="remember-me"> Remember me
          </label>
        </div>
        <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
      </form>

    </div> <!-- /container -->
	'
};

1;
=encoding utf-8

=head1 AUTHOR

Václav Dovrtěl E<lt>vaclav.dovrtel@gmail.comE<gt>
