package Image::ANSI::Palette::VGA;

use base qw( Image::ANSI::Palette );

=head1 NAME

Image::ANSI::Palette::VGA - The default VGA palette

=head1 SYNOPSIS

	$pal = Image::ANSI::Palette::VGA->new;

=cut

use strict;
use warnings;

our $VERSION = '0.10';

my $palette = [
	[ 0x00, 0x00, 0x00 ], # black
	[ 0xaa, 0x00, 0x00 ], # red
	[ 0x00, 0xaa, 0x00 ], # green
	[ 0xaa, 0x55, 0x00 ], # yellow
	[ 0x00, 0x00, 0xaa ], # blue
	[ 0xaa, 0x00, 0xaa ], # magenta
	[ 0x00, 0xaa, 0xaa ], # cyan
	[ 0xaa, 0xaa, 0xaa ], # white
	                      # bright
	[ 0x55, 0x55, 0x55 ], # black
	[ 0xfe, 0x55, 0x55 ], # red
	[ 0x55, 0xfe, 0x55 ], # green
	[ 0xfe, 0xfe, 0x55 ], # yellow
	[ 0x55, 0x55, 0xfe ], # blue
	[ 0xfe, 0x55, 0xfe ], # magenta
	[ 0x55, 0xfe, 0xfe ], # cyan
	[ 0xfe, 0xfe, 0xfe ]  # white
];

=head1 METHODS

=head2 new( )

Creates a new Image::ANSI::Palette:VGA object.

=cut

sub new {
	my $class = shift;
	my $self  = $class->SUPER::new( $palette );

	return $self;
}

=head1 AUTHOR

=over 4 

=item * Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2004-2009 by Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;
