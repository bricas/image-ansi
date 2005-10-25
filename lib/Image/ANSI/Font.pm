package Image::ANSI::Font;

use base qw( Class::Accessor );

=head1 NAME

Image::ANSI::Font - A base class for fonts

=head1 SYNOPSIS

	# use 8x8, 8x16, or your own
	$font = Image::ANSI::Font::8x8->new;

=cut

use strict;
use warnings;

use GD;
use File::Temp;

our $VERSION = '0.02';

__PACKAGE__->mk_accessors( qw( width height characters ) );

=head1 METHODS

=head2 new( [$chars] )

Creates a new Image::ANSI::Font object.

=cut

sub new {
	my $class   = shift;
	my $chars   = shift;
	my $self    = {};

	bless $self, $class;

	$self->chars( $chars ) if $chars;

	return $self;
}

=head2 clear( )

Clears any in-memory data.

=cut

sub clear {
	my $self = shift;

	$self->chars( [] );
}

=head2 chars( [$chars] )

sets the character set. $chars should be an array (either 256 or 512 [the number of
characters]) of arrays (from 1 to 32 [1 bitmask per scanline]).

=cut

sub chars {
	my $self  = shift;
	my $chars = $_[ 0 ];

	if( @_ ) {
		if( @$chars == 0 ) {
			$self->{ _CHARS } = [];
			$self->height( 0 );
			$self->width( 0 );
			$self->characters( 0 );
		}
		else {
			$self->width( 8 );
			$self->height( scalar @{ $chars->[ 0 ] } );
			$self->characters( 0 );
			for( 0..@$chars - 1 ) {
				$self->char( $_, $chars->[ $_ ] );
			}
		}
	}

	return $self->{ _CHARS };
}

=head2 char( $index, [$char] )

Get / set a char in the font.

=cut

sub char {
	my $self  = shift;
	my $index = shift;
	my $char  = $_[ 0 ];

	if( @_ ) {
		my $chars = $index + 1;
		$self->characters( $chars ) if $chars > $self->characters;
		$self->{ _CHARS }->[ $index ] = $char;
	}
	
	return $self->{ _CHARS }->[ $index ];
}

=head2 intensity_map( )

Returns an array ref of intensity numbers (one for each character) for use when creating
a thumbnail image.

=cut

sub intensity_map {
	return [
		0,  50, 83, 49, 16, 33, 32, 0,  136, 0,  119, 18,  32, 18,  35, 33,
		99, 16, 16, 33, 48, 66, 4,  17, 16,  0,  16,  16,  33, 16,  18, 48,
		0,  16, 16, 34, 50, 17, 34, 0,  0,   0,  16,  0,   0,  16,  0,  1,
		67, 16, 19, 17, 32, 65, 66, 32, 66,  48, 0,   0,   0,  17,  0,  32,
		51, 51, 50, 50, 50, 50, 50, 50, 83,  0,  2,   50,  34, 83,  83, 50,
		50, 67, 50, 34, 16, 66, 65, 66, 34,  32, 35,  16,  32, 0,   16, 1,
		0,  18, 50, 34, 18, 34, 34, 36, 50,  0,  1,   50,  0,  35,  17, 34,
		19, 35, 18, 17, 16, 34, 17, 35, 17,  36, 18,  0,   0,  0,   16, 18,
		50, 66, 34, 18, 34, 18, 18, 16, 50,  50, 50,  16,  16, 16,  51, 51,
		50, 18, 67, 34, 50, 34, 66, 50, 67,  50, 66,  32,  50, 16,  99, 17,
		18, 0,  34, 50, 49, 99, 16, 16, 18,  18, 16,  66,  66, 0,   16, 17,
		17, 68, 85, 0,  16, 32, 33, 17, 32,  49, 17,  33,  48, 32,  32, 16,
		0,  16, 16, 0,  16, 16, 0,  17, 16,  1,  48,  33,  17, 32,  49, 32,
		32, 32, 17, 16, 0,  0,  1,  33, 32,  16, 0,   136, 24, 119, 0,  112,
		35, 37, 83, 33, 34, 35, 18, 16, 17,  50, 50,  17,  33, 34,  17, 51,
		33, 1,  0,  0,  0,  3,  0,  17, 16,  0,  0,   17,  48, 48,  33, 0
	];    
}

=head2 as_gd( )

Returns a GD::Font object.

=cut

sub as_gd {
	my $self = shift;
	my $temp = File::Temp->new;

	binmode( $temp );

	print $temp pack( 'LLLL', $self->characters, 0, $self->width, $self->height );
	for my $char ( @{ $self->chars } ) {
		print $temp pack( 'C*', split( //, sprintf( '%08b', $_ ) ) ) for @$char;
	}
	close $temp;

	return GD::Font->load( $temp->filename );
}

=head2 characters( [$characters] )

Returns or sets the number of characters in the font

=head2 width( [$width] )

Returns or sets the width of the font.

=head2 height( [$height] )

Returns or sets the number of scanlines in each of the characters in the font

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