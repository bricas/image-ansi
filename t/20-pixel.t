use Test::More tests => 18;

use strict;
use warnings;

use_ok( 'Image::ANSI' );
use_ok( 'Image::ANSI::Pixel' );

my $pixel = Image::ANSI::Pixel->new;
isa_ok( $pixel, 'Image::ANSI::Pixel' );

$pixel->fg( 15 );
$pixel->bg( 7 );
$pixel->blink( 1 );
$pixel->char( 'X' );

is( $pixel->fg, 15, 'fg' );
is( $pixel->bg, 7, 'bg' );
is( $pixel->blink, 1, 'blink' );
is( $pixel->char, 'X', 'char' );
is( $pixel->attr, 255, 'attr' );

$pixel = Image::ANSI::Pixel->new;
$pixel->attr( 255 );
$pixel->char( 'X' );

is( $pixel->fg, 15, 'fg' );
is( $pixel->bg, 7, 'bg' );
is( $pixel->blink, 1, 'blink' );

my $ansi = Image::ANSI->new;
isa_ok( $ansi, 'Image::ANSI' );

$ansi->putpixel( 0, 0, $pixel );

is( $ansi->width, 1, 'width' );
is( $ansi->height, 1, 'height' );

{
	my $pixel = $ansi->getpixel( 0, 0 );

	is( $pixel->fg, 15, 'fg' );
	is( $pixel->bg, 7, 'bg' );
	is( $pixel->blink, 1, 'blink' );
	is( $pixel->char, 'X', 'char' );
}

