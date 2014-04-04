## no critic (RCS,VERSION)

use strict;
use warnings;

use ExtUtils::MakeMaker;

## no critic (may require interpolation eval)

WriteMakefile(
    NAME               => 'It',
    AUTHOR             => q{David Oswald <davido [@at] cpan [d.o.t] org>},
    VERSION_FROM       => 'lib/It.pm',
    ABSTRACT_FROM      => 'lib/It.pm',
    LICENSE            => 'perl',
    MIN_PERL_VERSION   => '5.008000',
    PL_FILES           => {},
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '6.62',    # Core, but updated version.
    },
    BUILD_REQUIRES => {
        'Test::More' => '0.98',             # Core, but updated version.
        'English'    => '0',                # Core.
    },
    PREREQ_PM => {},
    META_MERGE => {
        'meta-spec'   => { version => 2 },
        resources     => {
            repository => {
                type  => 'git',
                url   => 'https://github.com/daoswald/It.git',
                web   => 'https://github.com/daoswald/It',
            },
        },
        provides      => {
            'It' => {
                file    => 'lib/It.pm',
                version => '0.20',
            },
        },
        prereqs => {
        },
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'List-BinarySearch-*' },
);
