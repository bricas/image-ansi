use Test::More tests => 40;

use strict;
use warnings;

use_ok( 'Image::ANSI::Font' );
use_ok( 'Image::ANSI::Font::8x8' );
use_ok( 'Image::ANSI::Font::8x16' );

{
    my $font = Image::ANSI::Font->new;
    isa_ok( $font, 'Image::ANSI::Font' );
	is( $font->characters, 0 );
	is( scalar @{ $font->chars }, 0 );
	
	$font->char( 0, [ 255 ] );
	$font->width( 8 );
	is( $font->width, 8 );
	is( $font->height, 1 );
	is( $font->characters, 1 );
    is( scalar @{ $font->chars }, 1 );
	
	$font->clear;
	is( $font->characters, 0 );
	is( scalar @{ $font->chars }, 0 );
	
	$font->chars( [ [ 255 ] ] );
	is( $font->characters, 1 );
	is( scalar @{ $font->chars }, 1 );
}

{
    my $font = Image::ANSI::Font::8x8->new;
    isa_ok( $font, 'Image::ANSI::Font::8x8' );
    isa_ok( $font, 'Image::ANSI::Font' );
	is( $font->width, 8 );
	is( $font->height, 8 );
	is( $font->characters, 256 );
	is( scalar @{ $font->chars }, 256 );
	is( ref $font->intensity_map, 'ARRAY' );

	is_deeply( $font->char( 0 ), [ ( 0 ) x 8 ] );

	my $gd = $font->as_gd;
	isa_ok( $gd, 'GD::Font' );
	is( $gd->width, 8 );
	is( $gd->height, 8 );
	is( $gd->nchars, 256 );

	$font->char( 0, [ ( 1 ) x 8 ] );
	is_deeply( $font->char( 0 ), [ ( 1 ) x 8 ] );
}

{
    my $font = Image::ANSI::Font::8x16->new;
    isa_ok( $font, 'Image::ANSI::Font::8x16' );
    isa_ok( $font, 'Image::ANSI::Font' );
	is( $font->width, 8 );
	is( $font->height, 16 );
	is( $font->characters, 256 );
	is( scalar @{ $font->chars }, 256 );
	is( ref $font->intensity_map, 'ARRAY' );

	is_deeply( $font->char( 0 ), [ ( 0 ) x 16 ] );

	my $gd = $font->as_gd;
	isa_ok( $gd, 'GD::Font' );
	is( $gd->width, 8 );
	is( $gd->height, 16 );
	is( $gd->nchars, 256 );

	$font->char( 0, [ ( 1 ) x 16 ] );
	is_deeply( $font->char( 0 ), [ ( 1 ) x 16 ] );
}