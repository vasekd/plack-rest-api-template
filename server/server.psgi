# twiggy -r --workers 4 -l :6060 server.psgi

use strict;
use warnings;

use File::Basename qw(dirname);
use HTTP::Exception;

use Plack::Builder;
use Plack::App::URLMap;
use Plack::App::File;

use Plack::Session;
use Plack::Session::Store::DBI;
use Plack::Session::State::Cookie;

use YAML::AppConfig;
use File::ShareDir;

# My own modules
use lib qw(./lib server/lib);
#use lib qw(../Rest-HtmlVis/lib/ ../../Rest-HtmlVis/lib/);
#use lib qw(../Plack-Middleware-FormatOutput/lib/ ../../Plack-Middleware-FormatOutput/lib/);
#use lib qw(../Plack-Middleware-ParseContent/lib/ ../../Plack-Middleware-ParseContent/lib/);
#use lib qw(../Plack-App-REST/lib/ ../../Plack-App-REST/lib/);
use Log;
use Version;
use Auth::Store;

# Auth visualiser
use Rest::HtmlVis::Login;
use Rest::HtmlVis::Logout;

#----------------------------------------------------------------------
### Directory and config file
my $myDir = dirname(__FILE__);
my $myConf = $ENV{CONF} ? $ENV{CONF} : "$myDir/default.conf";

### Init Log Dispatch
my $log = Log::log();

### Init Const
my $const = YAML::AppConfig->new(file => $myConf);
$log->info('Read Configuration files:', $myConf);

### Set env
my $plackEnv = $const->get('PlackEnv');
if (exists $ENV{PLACK_ENV}) {
	if (lc($ENV{PLACK_ENV}) =~ /^(development|test|deployment)$/) {
		$plackEnv = $1;
	} else {
		$log->warn("PLACK_ENV should be either of 'development', 'test' or 'deployment', default '$plackEnv' will be used.");
	}
}
$log->info("Set Plack Env.");

### Init auth server's store
my $auth = Auth::Store->new( $const->get('DBDir') )->init();

### Set Version
$const->set('version', Version::readFromFile("$myDir/../VERSION"));

#----------------------------------------------------------------------
$log->info("Server starting...");
builder {

	### Log
	enable "LogDispatch", logger => $log;
	
	### AccessLog
	enable_if {$plackEnv eq 'development'} "Plack::Middleware::AccessLog",
	  logger => sub { $log->log(level => 'debug', message => @_) };

	### StackTrace
	enable_if {$plackEnv eq 'development'} "Plack::Middleware::StackTrace",
	  force => 1;

	### URL mapping
	my $urlmap = Plack::App::URLMap->new;

	### Favicon
	$urlmap->mount('/favicon.ico' => Plack::App::File->new( file => "$myDir/static/favicon.ico" ) );

	### Set static directory
	$urlmap->mount('/localstatic' => builder {
		enable 'Plack::Middleware::ConditionalGET';
		enable 'Plack::Middleware::ETag', cache_control => 'public, max-age=3600';
		enable 'Plack::Middleware::Static',
			path => qr/./,
			root => "$myDir/static";
	});

	### Mount htmlvis static files
	my $share = File::ShareDir::dist_dir('Rest-HtmlVis') || "../Rest-HtmlVis/share/";
	$urlmap->mount("/static" => Plack::App::File->new(root => $share));

	### Session info
	enable 'Session',
		state => Plack::Session::State::Cookie->new(
			session_key => $const->get("SecureSessionKey")
		),
		store => Plack::Session::Store::DBI->new(
			dbh => $auth->dbh
		);

	### Auth server
	my $authprefix = $const->get('AuthPrefix');
	my $authUrl = $authprefix;
	$urlmap->mount($authprefix => builder {

		enable 'FormatOutput', htmlvis => {
			'default.content' => '',
			login => 'Rest::HtmlVis::Login',
			logout => 'Rest::HtmlVis::Logout',
		};
		enable 'ParseContent';

		### URL mapping
		my $amap = Plack::App::URLMap->new;

		my $authMap = $const->get('AuthMap');
		foreach my $res (sort keys %{$authMap}) {
			eval "require ".$authMap->{$res};
			die $@ if $@;
			$amap->mount( $res => $authMap->{$res}->new($auth) );
			$authUrl .= $res if $res eq '/login';
		}
		$amap->to_app;
	});

	### Load resources
	my $prefix = $const->get('ApiPrefix');
	my $restMap = $const->get('RestMap');

	foreach my $ver (sort keys %{$restMap}) {
		my $map = $restMap->{$ver};
		$urlmap->mount($prefix.'/'.$ver => builder {
			### Rest Middlewares
			enable 'FormatOutput';
			enable 'ParseContent';

			# Check user 
			enable '+Plack::Middleware::CheckUserAccess', login_url => $authUrl;

			### URL mapping
			my $apimap = Plack::App::URLMap->new;

			foreach my $path (sort keys %{$map}){
				eval "require ".$map->{$path};
				die $@ if $@;
				$apimap->mount( $path => $map->{$path}->new() );
			}
			$apimap->to_app;
		});
	}

	### Set the client
	$urlmap->mount("/" => Plack::App::File->new(file => "$myDir/static/index.html"));

	$log->info("Server started.");
	$urlmap->to_app;
};


=old
package HTTP::Exception::4XX;

sub allow {
	$_[0]->{allow} = $_[1] if (@_ > 1);
	return defined $_[0]->{allow} ? $_[0]->{allow} : '';
}

sub Fields {
	my $self    = shift;
	my @fields  = $self->SUPER::Fields();
	push @fields, qw(allow); # additional Fields
	return @fields;
}
=cut

__END__

