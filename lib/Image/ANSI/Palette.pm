package Image::ANSI::Palette;

=head1 NAME

Image::ANSI::Palette - A base class palettes

=head1 SYNOPSIS

	# use Image::ANSI::Palette::VGA or your own
	$pal = Image::ANSI::Palette:VGA->new;

=cut

use strict;
use warnings;

our $VERSION = '0.02';

=head1 METHODS

=head2 new( [$palette] )

Creates a new Image::ANSI::Palette object.

=cut

sub new {
	my $class   = shift;
	my $palette = shift;
	my $self    = {};

	bless $self, $class;

	if( $palette ) {
		for( 0..@$palette ) {
			$self->set( $_, $palette->[ $_ ] );
		}
	}

	return $self;
}

=head2 get( $index )

Get the rgb triple at index $index

=cut

sub get {
	my $self  = shift;
	my $index = shift;

	return $self->{ data }->[ $index ]; 
}

=head2 set( $index, $rgb )

Write an rgb triple at index $index

=cut

sub set {
	my $self = shift;
	my ( $index, $rgb ) = @_;

	$self->{ data }->[ $index ] = $rgb; 
}

=head2 clear( )

Clears any in-memory data.

=cut

sub clear {
	my $self = shift;

	$self->{ data } = [];
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