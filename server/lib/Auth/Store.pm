package Auth::Store;

#use Authen::Simple::DBI;
use DBI;
use DBD::SQLite;

use Log;

use strict;
use warnings;

use Digest::MD5 1.0 qw(md5_base64);

use Plack::Util::Accessor qw(dsnString dbh log dbString presc);

sub new {
	my ($class, $dbDir) = @_;

	### Init Log Dispatch
	my $log = Log::log();
	my $dsnString = 'dbi:SQLite:dbname='.$dbDir."/auth";

	my $presc = {
		users => {
			table => "users",
			columns => {
				login => "VARCHAR NOT NULL",
				password => "VARCHAR NOT NULL",
				email => "VARCHAR NOT NULL",
			}
		},
		sessions => {
			table => "sessions",
			columns => {
				"id" => "CHAR(72) PRIMARY KEY",
				"session_data" => "TEXT"
			}
		}
	};

	return bless {
		log => $log,
		dbDir => $dbDir,
		dsnString => $dsnString,
		presc => $presc
	}, $_[0];
}

sub init {
	my ($self) = shift;

	$self->dbh(DBI->connect($self->dsnString,"","", {
		AutoCommit => 1,
		RaiseError => 1,
		PrintError => 0,
		sqlite_see_if_its_a_number => 1, # in bind param
	}));
	$self->log->info('Auth server: db initialized.');

	if (!$self->checkTables){
		### create tables
		$self->createSchema();
	}

	$self->log->info('Auth server: table initialized.');
	return $self;
}

sub checkTables {
	my ($self) = @_;

	foreach my $id (keys %{$self->presc}){
		my @columns;
		foreach my $c (keys %{$self->presc->{$id}{columns}}){
			push @columns, $c.' '.$self->presc->{$id}{columns}{$c};
		};

		my ($e) = eval{ $self->dbh->selectrow_array(
			sprintf( "SELECT %s FROM %s", join(",", @columns), $self->presc->{$id}{table})
		)};

		return undef unless $@;
	}
	return 1;
}

sub addUser {
	my ($self, $login, $passwd_nc, $email) = @_;

	# Crypt passwd
	my $password = $self->getPasswd($passwd_nc);

	my ($e) = $self->dbh->do("INSERT INTO users (login, password, email) VALUES (?,?,?)", $login, $password, $email);
	return ($e ? $login : 0);
}

sub createSchema {
	my ($self) = @_;

	foreach my $id (keys %{$self->presc}){
		my @columns;
		foreach my $c (keys %{$self->presc->{$id}{columns}}){
			push @columns, $c.' '.$self->presc->{$id}{columns}{$c};
		};

		$self->dbh->do(sprintf('DROP TABLE IF EXISTS %s',$self->presc->{$id}{table})) or $self->dbh->err;
		$self->dbh->do(sprintf("CREATE TABLE IF NOT EXISTS %s (%s)", $self->presc->{$id}{table}, join(",\n", @columns) )) or $self->dbh->err;
	}
}

sub checkUser {
	my ($self, $env, $login, $passwd_nc) = @_;

	return 0 unless $login;

	# Crypt passwd
	my $password = $self->getPasswd($passwd_nc);

	# Check user
	my ($user) = $self->dbh->selectrow_array( "SELECT login FROM users WHERE login = ? AND password = ?", undef, $login, $password );

	if ( $user ){
		return $user;
	}else{
		return 0;
	}
}

sub getPasswd {
	return md5_base64($_[1]);
}

1;