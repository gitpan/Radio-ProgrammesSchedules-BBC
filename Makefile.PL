use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Radio::ProgrammesSchedules::BBC',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/Radio/ProgrammesSchedules/BBC.pm',
    ABSTRACT_FROM => 'lib/Radio/ProgrammesSchedules/BBC.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'Radio-ProgrammesSchedules-BBC*' },
    PREREQ_PM     => {
        'Test::More'      => 0,
        'Readonly'        => '1.03',
        'HTML::Entities'  => '1.35',
        'Time::localtime' => '1.02',
        'HTTP::Request'   => '1.40',
        'LWP::UserAgent'  => '2.33',
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);