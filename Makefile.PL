use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'POE::Attributes',
    AUTHOR              => q{M. Nunberg <mnunberg@hakalah.org>},
    VERSION_FROM        => 'lib/POE/Attributes.pm',
    ABSTRACT_FROM       => 'lib/POE/Attributes.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'            => 0,
        'Constant::Generate'    => 0.03,
        'POE'                   => 0,
        'Attribute::Handlers'   => 0,
        'Log::Fu'               => 0.25,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'POE-Attributes-*' },
);
