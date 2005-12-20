use Test::More tests => 43;

use strict;
use warnings;

use_ok( 'Image::ANSIMation' );
use_ok( 'Image::ANSIMation::Parser' );

my $parser = Image::ANSIMation::Parser->new;
isa_ok( $parser, 'Image::ANSIMation::Parser' );

{
    my $ansimation = $parser->parse( file => 't/data/ansimation1.ans' );
    isa_ok( $ansimation, 'Image::ANSIMation' );
    is( $ansimation->width, 4 );
    is( $ansimation->height, 1 );
    is( scalar @{ $ansimation->frames }, 2 );

    check_results( $ansimation->frames->[ 0 ] );
    check_results( $ansimation->frames->[ 1 ] );
}

sub check_results {
    my $ansi = shift;
    is( $ansi->width, 4 );
    is( $ansi->height, 1 );

    {
        my $pixel = $ansi->getpixel( 0, 0 );
        is( $pixel->char, 'T' );
        is( $pixel->fg, 8 );
        is( $pixel->bg, 0 );
        is( $pixel->blink, 0 );
    }
    {
        my $pixel = $ansi->getpixel( 1, 0 );
        is( $pixel->char, 'E' );
        is( $pixel->fg, 15 );
        is( $pixel->bg, 4 );
        is( $pixel->blink, 1 );
    }
    {
        my $pixel = $ansi->getpixel( 2, 0 );
        is( $pixel->char, 'S' );
        is( $pixel->fg, 4 );
        is( $pixel->bg, 4 );
        is( $pixel->blink, 0 );
    }
    {
        my $pixel = $ansi->getpixel( 3, 0 );
        is( $pixel->char, 'T' );
        is( $pixel->fg, 3 );
        is( $pixel->bg, 2 );
        is( $pixel->blink, 0 );
    }
}