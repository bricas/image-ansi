package Image::ANSI::Utils;

=head1 NAME

Image::ANSI::Utils - Utility funtions

=head1 SYNOPSIS

	use Image::ANSI::Utils
	
	my $file = create_io_object( file => $file );

=cut

use strict;
use warnings;

use base qw( Exporter );

our @EXPORT  = qw( create_io_object );
our $VERSION = '0.10';

use IO::File;
use IO::String;
use Carp;

=head1 METHODS

=head2 create_io_object( %options, $perms )

Creates an IO::File object or IO::String object.

	# for reading...
	$file = create_io_object( file => $file, '<' );
	$file = create_io_object( handle => $handle, '<' );
	$file = create_io_object( string => \$string, '<' );

=cut

sub create_io_object {
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

Copyright 2004-2009 by Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;
