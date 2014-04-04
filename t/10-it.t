use strict;
use warnings;

use Test::More;

# Load
use_ok 'It';

# Instantiate.
my $it = new_ok 'It', [ sub{}              ], 'Code ref constructed object';
$it    = new_ok 'It', [ code => sub{}      ], 'Flat list constructed object';
$it    = new_ok 'It', [ { code => sub {} } ], 'Hash-ref constructed';

# Instantiation error checking.
ok ! eval { my $it = It->new; 1; },
  'Object instantiation dies when constructor called without args.';
like $@, qr/constructor requires a CODE or "code/, 'Correct error.';

ok ! eval { my $it = It->new(invalid=>1); 1; },
  'Object instantiation dies when constructor called without a CODE ref.';
like $@, qr/Missing required arguments: code/, 'Correct error.';

# Overloading.

# &{}
$it = It->new( sub { shift } );
is $it->('Hello world!'), 'Hello world!', '&{} is overloaded.';

# ""
$it = It->new( sub { 'Hello world!' } );
is "$it", 'Hello world!', '"" is overloaded.';

# <>
is <$it>, 'Hello world!', '<> is overloaded.';
$it = make_countdown(10);
my @rv = <$it>;
is scalar @rv, 10, '<> returns correct size list in list context.';
is_deeply [@rv], [reverse 1 .. 10], '<> in list context: correct list.';

# @{}
@rv = @{ make_countdown(10) };
is_deeply [@rv], [reverse 1 .. 10], '@{} is overloaded.';
is scalar @rv, 10, '@{} returns correct number of values.';

sub make_countdown {
  my $top = shift;
  return It->new(
    sub { return if !$top; $top--; }
  );
}

# Closures.
sub make_it {
  my $max = shift;
  my $val = 0;
  return It->new(
    sub {
      my $self = shift;
      return if $val == $max;
      return $val++;
    }
  );
}

# (0..$end]
my $end = 10;
$it = make_it($end);
for( 0 .. $end ) {
  if ( $_ == $end ) {
    is $it->(), undef, 'Iterator expires.';
  }
  else {
    is $it->(), $_, "Iterator is at $_.";
  }
}

# Unspecified sentinel should default to the 'undef' value.
ok !$it->has_sentinel, 'Sentinel not specified.';
is $it->sentinel, undef, 'Sentinel defaults to undef.';
my( @list_context ) = $it->sentinel;
is scalar @list_context, 1, 'Default sentinel, list context => single value.';
is $list_context[0], undef, 'Single value is undef.';


# Explicit sentinel using 'undef'
$it = It->new( code => sub { 'Hello world.' }, sentinel => undef );
ok $it->has_sentinel, 'Sentinel is specified explicitly (undef).';
is $it->sentinel, undef, 'undef in scalar context.';
(@list_context) = $it->sentinel;
is scalar @list_context, 1, 'Explicit sentinel, list context => single value.';
is $list_context[0], undef, 'Single value undef.';

# Explicit sentinel using an array-ref.
my $s = [];
$it = It->new( code => sub {}, sentinel => $s );
(@list_context) = $it->sentinel;
is scalar @list_context, 1, 'Aref sentinel, list context => single value.';
is $list_context[0], $s, 'Verified same aref.';
isnt $list_context[0], [], 'Reject different aref.';

# _gather (sentinel)
{
  my $x = 10;
  $it = It->new(
    sentinel => 1,
    code     => sub{ return $x-- }
  );
  my @rv = <$it>;
  is scalar @rv, 9, '_gather stops at correct sentinel value.'
}

done_testing;
