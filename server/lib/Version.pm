################################################################################
#	Package: Version
################################################################################

package Version;

use strict;
use warnings;

use File::Basename qw(dirname basename);

################################################################################
#	Group: Exports
################################################################################

#-------------------------------------------------------------------------------
# Function: readFromFile
#  Reads version from VERSION file.
#  Try to read file given as parameter at first (typical for std. deployment), if not exists,
#  then try to read same file in the parent directory (typical for development)
#
# Parameters:
#  file - path to a file to load, typically './VERSION';
#
# Returns:
#  string - version number
#-------------------------------------------------------------------------------
sub readFromFile {
	my $fn = shift;

	unless (open V, $fn) {
		my $f = dirname($fn) . '/../' . basename($fn);
		open V, $f or die "Can't open either $fn or $f file for read: $!\n";
	}

	my $ret;
	foreach (<V>) {
		if (m/^Version:\s+(\d+\.\d+\.\d+)(.dev)?\s+$/) {
			$ret = $1;
			last;
		}
	}
	close V;
	die "Wrong format of VERSION file" unless $ret;

	return $ret;
}

#-------------------------------------------------------------------------------

1;

__END__

