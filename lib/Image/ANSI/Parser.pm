package Image::ANSI::Parser;

=head1 NAME

Image::ANSI::Parser - Reads in ANSI files

=head1 SYNOPSIS

	my $parser = Image::ANSI::Parser->new;
	my $ansi   = $parser->parse( file => 'file.ans' );

=cut

use base qw( Class::Accessor );

use warnings;
use strict;

use Carp;
use Image::ANSI;
use Image::ANSI::Pixel;

# State definitions
use constant S_TXT      => 0;
use constant S_CHK_B    => 1;
use constant S_WAIT_LTR => 2;
use constant S_END      => 3;

use constant TABSTOP    => 8;

our $VERSION  = '0.05';
my @accessors = qw( save_x save_y attr state );

__PACKAGE__->mk_accessors( @accessors );

=head1 METHODS

=head2 new( [%options] )

Creates a new parser object and reads in a file, handle or string.

=cut

sub new {
	my $class = shift;
	my $self  = {};

	bless $self, $class;

	$self->clear;

	return $self->parse( @_ ) if @_;

	return $self;
}

=head2 clear( )

Clears the internal ANSI object.

=cut

sub clear {
	my $self = shift;

	$self->$_( 0 ) for qw( x y save_x save_y attr );
	$self->ansi( Image::ANSI->new );

	# default to white on black;
	$self->set_attributes( 37 );
}

=head2 parse( %options )

Reads in a file, handle or string

	my $parser = Image::ANSI::Parser->new;

	# filename
	$ansi = $parser->parse( file => 'file.ans' );
	
	# file handle
	$ansi = $parser->parse( handle => $handle );

	# string
	$ansi = $parser->parse( string => $string );

=cut

sub parse {
	my $self    = shift;
	my %options = @_;
	my $file    = $self->_create_io_object( \%options, '<' );

	my( $argbuf, $ch );

	$self->clear;

	$self->ansi->sauce->read( handle => $file );

	$self->state( S_TXT );

	seek( $file, 0, 0 );
	while( $file->read( $ch, 1 ) ) {
		my $state = $self->state;
		if( $state == S_TXT ) {
			if( $ch eq "\x1a" ) {
				$self->state( S_END );
			}
			elsif( $ch eq "\x1b" ) {
				$self->state( S_CHK_B );
			}
			elsif( $ch eq "\n" ) {
				$self->new_line;
			}
			elsif( $ch eq "\r" ) {
				# do nothing
			}
			elsif( $ch eq "\t" ) {
				$self->tab;
			}
			else {
				$self->store( $ch );
			}
		}
		elsif( $state == S_CHK_B ) {
                	if( $ch ne '[' ) {
				$self->store( chr( 27 ) );
				$self->store( $ch );
				$self->state( S_TXT );
			}
			else {
				$self->state( S_WAIT_LTR );
			}
		}
		elsif( $state == S_WAIT_LTR ) {
			if( $ch =~ /[a-zA-Z]/ ) {
				my @args = split( /;/, $argbuf );

				if( $ch eq 'm' ) {
					$self->set_attributes( @args );
				}
				elsif( $ch eq 'H' or $ch eq 'f' ) {
					$self->set_position( @args );
				}
				elsif( $ch eq 'A' ) {
					$self->move_up( @args );
				}
				elsif( $ch eq 'B' ) {
					$self->move_down( @args );
				}
				elsif( $ch eq 'C' ) {
					$self->move_right( @args );
				}
				elsif( $ch eq 'D' ) {
					$self->move_left( @args );
				}
				elsif( $ch eq 's' ) {
					$self->save_position( @args );
				}
				elsif( $ch eq 'u' ) {
					$self->restore_position( @args );
				}
				elsif( $ch eq 'J' ) {
					$self->clear_screen( @args );
				}
				elsif( $ch eq 'K' ) {
					$self->clear_line( @args );
				}

				$argbuf = '';
				$self->state( S_TXT );
			}
			else {
				$argbuf .= $ch;
			}
		}
		elsif( $state == S_END ) {
			last;
		}
		else {
			$self->state( S_TXT );
		}
	}

	return $self->ansi;
}


=head2 ansi( [$ansi] )

Gets / sets the internal ANSI object.

=cut

sub ansi {
	my $self    = shift;
	my( $ansi ) = @_;

	if( @_ ) {
		$self->{ _ANSI } = $ansi;
	}

	return $self->{ _ANSI };
}

=head2 x( [$x] )

stores the current 'x' location.

=cut

sub x {
	my $self = shift;
	my $data = shift;

	$self->{ x } = $data if defined $data;

	if( $self->{ x } < 0 ) {
		$self->{ x } = 0;
	}

	return $self->{ x };
}

=head2 y( [$y] )

stores the current 'y' location.

=cut

sub y {
	my $self = shift;
	my $data = shift;

	$self->{ y } = $data if defined $data;

	if( $self->{ y } < 0 ) {
		$self->{ y } = 0;
	}

	return $self->{ y };
}

# Handlers

=head2 set_position( [$x, $y] )

sets the x() and y() positions.

=cut


sub set_position {
	my $self = shift;
	my $y    = shift || 1;
	my $x    = shift || 1;

	$self->x( $x - 1 );
	$self->y( $y - 1 );
}

=head2 set_attributes( @attributes )

sets the attributes of the pixel (fg, bg, blinking)

=cut

sub set_attributes {
	my $self = shift;
	my @args = @_;

	foreach( @args ) {
		if( $_ == 0 ) {
			$self->attr( 7 );
		}
		elsif( $_ == 1 ) {
			$self->attr( $self->attr | 8 );
		}
		elsif( $_ == 5 ) {
			$self->attr( $self->attr | 128 );
		}
		elsif( $_  >= 30 and $_ <= 37 ) {
			$self->attr( $self->attr & 248 );
			$self->attr( $self->attr | ( $_ - 30 ) );
		}
		elsif( $_  >= 40 and $_ <= 47 ) {
			$self->attr( $self->attr & 143 );
			$self->attr( $self->attr | ( ( $_ - 40 ) << 4 ) );
		}
	}
}

=head2 move_up( [$number] )

moves y() up by $number (default 1).

=cut

sub move_up {
	my $self = shift;
	my $y    = shift || 1;

	$self->y( $self->y - $y );
}

=head2 move_down( [$number] )

moves y() down by $number (default 1).

=cut


sub move_down {
	my $self = shift;
	my $y    = shift || 1;

	$self->y( $self->y + $y );
}

=head2 move_right( [$number] )

moves x() right by $number (default 1).

=cut

sub move_right {
	my $self = shift;
	my $x    = shift || 1;

	$self->x( $self->x + $x );
}

=head2 move_left( [$number] )

moves x() left by $number (default 1).

=cut

sub move_left {
	my $self = shift;
	my $x    = shift || 1;

	$self->x( $self->x - $x );
}

=head2 save_position( )

saves the current x() and y() positions.

=cut

sub save_position {
	my $self = shift;

	$self->save_x( $self->x );
	$self->save_y( $self->y );
}

=head2 restore_position( )

restored the saved x() and y() positions.

=cut

sub restore_position {
	my $self = shift;

	$self->x( $self->save_x );
	$self->y( $self->save_y );
}

=head2 clear_line( )

clears the pixels on the current line.

=cut

sub clear_line {
	my $self = shift;

	$self->ansi->clear_line( $self->y );
}

=head2 clear_screen( )

clears all pixels.

=cut

sub clear_screen {
	my $self = shift;

	$self->ansi->clear;
}

=head2 new_line( )

simulates a newline char.

=cut

sub new_line {
	my $self = shift;

	$self->y( $self->y + 1 );
	$self->x( 0 );
}

=head2 tab( )

simulates a tab char (8 spaces).

=cut


sub tab {
	my $self = shift;
	my $count = ( $self->x + 1 ) % TABSTOP;
	if( $count ) {
		$count = TABSTOP - $count;
		for( 1..$count ) {
			$self->store( ' ' );
		}
	}
}

=head2 store( $char, $x, $y [, $attr] )

stores $char at position $x, $y using attributes $attr
(or the current attr setting if none are supplied).

=cut

sub store {
	my $self = shift;
	my $char = shift;
	my $x    = shift;
	my $y    = shift;
	my $attr = shift || $self->attr;

	if( defined $x and defined $y ) {
		$self->putpixel( $x, $y, $char, $attr );
	}
	else {
		$self->putpixel( $self->x, $self->y, $char, $attr );
		$self->x( $self->x + 1 );
	}
}

=head2 putpixel( @args )

same as the pixel() method

=cut

*putpixel = \&pixel;

=head2 getpixel( @args )

same as the pixel() method

=cut

*getpixel = \&pixel;

=head2 pixel( $x, $y [, $char, $attr] )

get/sets the pixel at $x, $y.

=cut

sub pixel {
	my $self = shift;
	my $x    = shift;
	my $y    = shift;
	my $char = shift;
	my $attr = shift;

	if( defined $char ) {
		my $pixel = Image::ANSI::Pixel->new( char => $char, attr => $attr );
		$self->ansi->putpixel( $x, $y, $pixel );
	}

	return $self->ansi->getpixel( $x, $y );
}

sub _create_io_object {
	my $self    = shift;
	my %options = %{ $_[ 0 ] };
	my $perms   = $_[ 1 ];

	my $file;

	# use appropriate IO object for what we get in
	if( exists $options{ file } ) {
		$file = IO::File->new( $options{ file }, $perms ) || croak "$!";
	}
	elsif( exists $options{ string } ) {
		$file = IO::String->new( $options{ string }, $perms );
	}
	elsif( exists $options{ handle } ) {
		$file = $options{ handle };
	}
	else {
		croak( "No valid read type. Must be one of 'file', 'string' or 'handle'." );
	}

	binmode( $file );
	return $file;
}

=head1 AUTHOR

=over 4 

=item * Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2005 by Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;
