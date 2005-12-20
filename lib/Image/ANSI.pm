package Image::ANSI;

=head1 NAME

Image::ANSI - Load, create, manipulate and save ANSI files

=head1 SYNOPSIS

	use Image::ANSI;

	# Read in a file...
	my $img = Image::ANSI->new( file => 'file.ans' );

	# Image width and height
	my $w = $img->width;
	my $h = $img->height;

	# get and put "pixels"
	my $pixel = $img->getpixel( $x, $y );
	$img->putpixel( $x, $y, $pixel );

	# create a thumbnail
	my $png = $img->as_png( mode => 'thumbnail' );

	# export it as a png
	my $png = $img->as_png( mode => 'full' );

	# use a custom font
	my $png = $img->as_png( mode => 'full', font => 'Image::ANSI::Font::8x8' );

=head1 DESCRIPTION

This module allows you to load, create and manipulate files made up of
ANSI escape codes, aka ANSI art.

=head1 INSTALLATION

To install this module via Module::Build:

	perl Build.PL
	./Build         # or `perl Build`
	./Build test    # or `perl Build test`
	./Build install # or `perl Build install`

To install this module via ExtUtils::MakeMaker:

	perl Makefile.PL
	make
	make test
	make install

=cut

use strict;
use warnings;

use Carp;
use File::SAUCE;

our $VERSION = '0.07';

=head1 METHODS

=head2 new( %options )

Creates a new ANSI image. Currently only reads in data.

	# filename
	$ansi = Image::ANSI->new( file => 'file.ans' );
	
	# file handle
	$ansi = Image::ANSI->new( handle => $handle );

	# string
	$ansi = Image::ANSI->new( string => $string );

=cut

sub new {
	my $class = shift;
	my $self = {};

	bless $self, $class;

	$self->clear;

	my %options = @_;
	if(
		exists $options{ file } or
		exists $options{ string } or
		exists $options{ handle }
	) {
		return $self->read( @_ );
	}
	else {
		# create new using options
	}

	return $self;
}

=head2 clear( )

Clears any in-memory data.

=cut

sub clear {
	my $self = shift;

	$self->{ image } = [];
	$self->height( 0 );
	$self->width( 0 );
}

=head2 read( %options )

Reads in an ANSI.

=cut

sub read {
	my $self = shift;

	require Image::ANSI::Parser;

	$self = Image::ANSI::Parser->new( @_ );

	return $self;
}

=head2 putpixel( $x, $y, $pixel )

Sets the pixel at $x, $y with $pixel (which should be an Image::ANSI::Pixel).

=cut

*putpixel = \&pixel;

=head2 getpixel( $x, $y )

Returns the Image::ANSI::Pixel object at $x, $y (or undef).

=cut

*getpixel = \&pixel;

=head2 pixel( [$x, $y, $pixel] )

Generic get / set method used by both getpixel and putpixel.

=cut

sub pixel {
	my $self = shift;
	my( $x, $y, $pixel ) = @_;

	return if ( !$pixel and $x > $self->width ) or $x < 0 or $y < 0;

	my $image = $self->{ image };
 	if( defined $pixel ) {
		$image->[ $y ] = [ ] unless defined $image->[ $y ];
		$image->[ $y ]->[ $x ] = $pixel;
		$self->height( $y + 1 ) if $y + 1 > $self->height;
		$self->width( $x + 1 ) if $x + 1 > $self->width;
	}

	return $image->[ $y ]->[ $x ];
}

=head2 width( )

Returns the image width.

=cut

sub width {
	my $self  = shift;
	my $width = shift;

	$self->{ _WIDTH } = $width if defined $width;

	return $self->{ _WIDTH };
}

=head2 height( )

Returns the image height.

=cut

sub height {
	my $self   = shift;
	my $height = shift;

	$self->{ _HEIGHT } = $height if defined $height;

	return $self->{ _HEIGHT };
}

=head2 sauce( [File::SAUCE] )

Gets / sets the SAUCE object associated with the ANSI.

=cut

sub sauce {
	my $self = shift;

	$self->{ _SAUCE } = File::SAUCE->new unless $self->{ _SAUCE };

	return $self->{ _SAUCE };
}

=head2 max_x( [$y] )

find the largest x on line $y (default 0 ).

=cut

sub max_x {
	my $self = shift;
	my $y    = shift || 0;

	my $max = 0;

	for my $x ( 0..$self->width - 1 ) {
		$max = $x if $self->getpixel( $x, $y );
	}

	return $max
}

=head2 clear_line( $y )

clears lines $y.

=cut

sub clear_line {
	my $self = shift;
	my $y    = shift;

	my $line = $self->{ image }->[ $y ];

	$self->{ image }->[ $y ] = [ ] if defined $line;
}

=head2 as_ascii( )

strip the attributes and return only the characters.

=cut

sub as_ascii {
	my $self = shift;

	my $output;

	for my $y ( 0..$self->height - 1 ) {
		my $max_x = $self->max_x( $y );
		for my $x ( 0..$max_x ) {
			my $pixel = $self->getpixel( $x, $y );
			$output .= ( defined $pixel ) ? $pixel->char : ' ';
		}
		$output .= "\n" unless $max_x == 79;
	}

	return $output;
}

=head2 as_png( [%options] )

Returns a binary PNG version of the image.

	# Thumbnail -- Default
	$ansi->as_png( mode => 'thumbnail' );

	# Full size
	$ansi->as_png( mode => 'full' );

This function is just a wrapper around as_png_thumbnail() and as_png_full().

=cut

sub as_png {
	my $self = shift;
	my %options;

	%options = @_ if @_ % 2 == 0;

	require GD;

	$options{ mode } = 'thumbnail' unless defined $options{ mode } and $options{ mode } eq 'full';

	if( $options{ mode } eq 'full' ) {
		$self->as_png_full( %options );
	}
	else {
		$self->as_png_thumbnail( %options );
	}
}

=head2 as_png_thumbnail( [%options] )

Creates a thumbnail version of the ANSI.

=cut

sub as_png_thumbnail {
	my $self   = shift;
	my %options;
	%options   = @_ if @_ % 2 == 0;
	$options{ zoom } = 1 unless defined $options{ zoom };

	my $font   = $self->_get_gd_font( $options{ font } );
	my $height = int( $font->height / 8 + 0.5 );
	$height    = 1 unless $height;
	my $width  = $self->width;
	my $crop   = ( defined $options{ crop } and $options{ crop } > 0 and $options{ crop } < $self->height ) ? $options{ crop } : $self->height;
	my $image  = GD::Image->new( $width, $crop * $height, 1 );

	my @colors;

	my $pal_class = $options{ palette } || 'Image::ANSI::Palette::VGA';
	eval "require $pal_class;";
	croak $@ if $@;

	my $palette   = $pal_class->new;
	for my $x ( 0..7 ){
		for my $y ( 0..15 ) {
			for my $z ( 0..8 ) {
				$colors[ $y * 8 + $x ]->[ 8 - $z ] = $image->colorAllocate(
					$z / 8  * ( $palette->get( $x )->[ 0 ] ) + ( 8 - $z ) / 8 * ( $palette->get( $y )->[ 0 ] ),
					$z / 8  * ( $palette->get( $x )->[ 1 ] ) + ( 8 - $z ) / 8 * ( $palette->get( $y )->[ 1 ] ),
					$z / 8  * ( $palette->get( $x )->[ 2 ] ) + ( 8 - $z ) / 8 * ( $palette->get( $y )->[ 2 ] ),
				);
			}
		}
	}

	my $intensity = $self->_get_intensity_map( $options{ font } );

	for my $y ( 0..$crop - 1 ) {
		for my $x ( 0..$width - 1 ) { 
			my $pixel = $self->getpixel( $x, $y );

			next unless $pixel;

			my $offset = ( $pixel->attr & 15 ) * 8 + ( $pixel->attr >> 4 );

			# for some reason some offsets are generated outside of our palette
			next if $offset > $#colors;

			unless( $height == 1 ) {
				$image->setPixel( $x, $y * $height + 1, $colors[ $offset ]->[ $intensity->[ ord( $pixel->char ) ] & 15 ] );
			}
			$image->setPixel( $x, $y * $height, $colors[ $offset ]->[ $intensity->[ ord( $pixel->char ) ] >> 4 ] );
		}
	}

	return $image->png unless $options{ zoom } > 1;

	my( $iwidth, $iheight ) = $image->getBounds;

	my $scalex = $iwidth * $options{ zoom };
	my $scaley = $iheight * $options{ zoom };

	my $image2 = GD::Image->new( $scalex, $scaley );
	$image2->copyResized( $image, 0, 0, 0, 0, $scalex, $scaley, $iwidth, $iheight );

	return $image2->png;
}

=head2 as_png_full( [%options] )

Creates a full-size replica of the ANSI. You can pass a "crop" option to
crop the image at certain height.

	# Crop it after 25 (text-mode) rows
	$ansi->as_png_full( crop => 25 );

=cut

sub as_png_full {
	my $self   = shift;
	my %options;
	%options   = @_ if @_ % 2 == 0;
	my $crop   = ( defined $options{ crop } and $options{ crop } > 0 and $options{ crop } < $self->height ) ? $options{ crop } : $self->height;

	my $font   = $self->_get_gd_font( $options{ font } );
	my $height = $font->height;
	my $width  = $font->width;

	my $image  = GD::Image->new( $self->width * $width, $crop * $height );

	my @colors;
	my $pal_class = $options{ palette } || 'Image::ANSI::Palette::VGA';
	eval "require $pal_class;";
	croak $@ if $@;

	my $palette   = $pal_class->new;
        for( 0..15 ) {
		push @colors, $image->colorAllocate(
			$_->[ 0 ],
			$_->[ 1 ],
			$_->[ 2 ]
		) for $palette->get( $_ );
        }

        for my $y (0..$crop - 1 ) {
		for my $x (0..$self->width - 1 ) {
			my $pixel = $self->getpixel( $x, $y );

			next unless $pixel;

			if( $pixel->bg ) {
				$image->filledRectangle( $x * $width, $y * $height, ( $x + 1 ) * $width, ( $y + 1 ) * $height - 1, $colors[ $pixel->bg ] );
			}

			$image->string( $font, $x * $width, $y * $height, $pixel->char, $colors[ $pixel->fg ] );
            }
        }

	return $image->png;
}

sub _get_gd_font {
	my $self = shift;
	my $font = shift;
	$font    = 'Image::ANSI::Font::8x16' unless $font;

	require GD;

	if( UNIVERSAL::isa( $font, 'GD::Font' ) ) {
		return $font;
	}
	elsif( $font =~ /\.fnt$/ ) {
		return GD::Font->load( $font );
	}
	else {
		eval "require $font;";
		croak $@ if $@;
		$font = $font->new;
		return $font->as_gd;
	}

	return $font;
}

sub _get_intensity_map {
	my $self = shift;
	my $font = shift;
	$font    = 'Image::ANSI::Font::8x16' unless $font;

	if( UNIVERSAL::isa( $font, 'GD::Font' ) or $font =~ /\.fnt$/ ) {
		return [];
	}
	else {
		eval "require $font;";
		croak $@ if $@;
		$font = $font->new;
		return $font->intensity_map;
	}
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