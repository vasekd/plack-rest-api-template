package Log;

use strict;
use warnings;

use File::Spec;
use FindBin;

#use Log::Dispatch::Screen::Color; ###used by Log::Dispatch::Config
#use Log::Dispatch::File; ###used by Log::Dispatch::Config
use Log::Dispatch::Config;

my (undef, $directory) = File::Spec->splitpath(__FILE__);
Log::Dispatch::Config->configure($directory.'../log.conf');

#debug
#info
#notice
#warning | warn
#error | err
#critical | crit
#alert
#emergency | emerg

sub log {
	Log::Dispatch::Config->instance;
}

1;
