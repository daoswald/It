package It;

use Moo;
use Carp qw(croak carp);

use overload
  '&{}'    => sub { shift->code                                       },
  '@{}'    => sub { return shift->_gather()                           },
  '""'     => sub { shift->code->()                                   },
  '<>'     => sub { wantarray ? @{shift->_gather()} : shift->code->() };

has code     => ( is => 'ro', isa       => sub { 'CODE' eq ref shift }, required => 1 );
has sentinel => ( is => 'ro', predicate => 'has_sentinel' );

sub BUILDARGS {
  my( $class, @args ) = @_;

  croak __PACKAGE__ . ' constructor requires a CODE or "code => CODE" param.'
    unless @args;                              # It's fatal if no iterator sub
                                               # is provided to constructor.

  return $args[0] if ref($args[0]) eq 'HASH';  # Handle a hash-ref of params.
  return { code => $args[0] } if @args == 1;   # Handle a subref only param.
  return { @args };                            # Handle a flat list of params.
}

sub _gather {
  my( $self, $quantity ) = @_;
  my @rv;

  if( $self->has_sentinel ) {
    my $sentinel = $self->sentinel;
    while( ( my $v = $self->code->() ) != $sentinel ) {
      push @rv, $v;
    }
  }
  else {
    while( defined( my $v = $self->code->() ) ) {
      push @rv, $v;
    }
  }

  return [@rv];
}

1;
