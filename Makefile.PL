use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Religion::Bible::Regex::Reference',
    AUTHOR              => 'Daniel Holmlund <holmlund.dev@gmail.com>',
    VERSION_FROM        => 'lib/Religion/Bible/Regex/Reference.pm',
    ABSTRACT_FROM       => 'lib/Religion/Bible/Regex/Reference.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Religion::Bible::Regex::Regex' => 0,
        'Religion::Bible::Regex::Config' => 0,
        'Test::Base' => 0,
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Religion-Bible-Regex-Reference-*' },
);
