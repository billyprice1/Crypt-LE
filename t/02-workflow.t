#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use File::Temp ();
use Crypt::LE ':errors';
$|=1;
plan tests => 14;

my $le = Crypt::LE->new(autodir => 0);

can_ok($le, 'directory');
can_ok($le, 'register');
can_ok($le, 'accept_tos');
can_ok($le, 'request_challenge');
can_ok($le, 'accept_challenge');
can_ok($le, 'verify_challenge');
can_ok($le, 'request_certificate');
can_ok($le, 'request_issuer_certificate');
can_ok($le, 'revoke_certificate');

# We don't want to ship the same account key to everyone with this module and
# we don't really want to pollute Let's Encrypt staging server with multiple odd
# registrations, so just making sure that interaction works.

# Account for the fact that some test boxes return 'Network is unreachable'.
my $rv = ($le->directory() == OK or $le->error_details=~/\bunreachable\b/i) ? 1 : 0;
ok($rv == 1, 'loading resources directory - ' . $le->error_details);

$le->{'domains'} = { 'x.dom' => undef, 'y.dom' => 0, 'z.dom' => 1 };
$le->{'failed_domains'} = [ [ qw<a.dom b.dom> ], undef ];

ok(@{$le->domains()} == 3, 'Checking the domains list');
ok(!defined $le->failed_domains(), 'Checking failed domains on the last verification call');
ok(@{$le->failed_domains(1)} == 2, 'Checking failed domains on any verification call');
ok(@{$le->verified_domains()} == 1, 'Checking verified domains');

diag( "Testing Crypt::LE $Crypt::LE::VERSION, Workflow methods, $^X" );
