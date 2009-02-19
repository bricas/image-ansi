use strict;

use Module::Build;

my $build = Module::Build->new(
	module_name        => 'Image::ANSI',
	dist_author        => 'Brian Cassidy <bricas@cpan.org>',
	license            => 'perl',
	create_readme      => 1,
	create_makefile_pl => 'traditional',
	script_files       => [ qw( bin/ans2png ) ],
	requires           => {
		'Class::Accessor' => 0,
		'File::SAUCE'     => 0,
		'GD'              => 0
	},
	build_requres      => {
		'Test::More' => 0,
	}
);

$build->create_build_script;