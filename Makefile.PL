
use ExtUtils::MakeMaker;

WriteMakefile(
    AUTHOR              => 'Kang-min Liu (gugod@gugod.org)',
    ABSTRACT            => 'Easy way to create social map',
    NAME                => 'Graph::SocialMap',
    VERSION             => '0.01_1',
    DISTNAME            => 'Graph-SocialMap',
    PREREQ_PM           => {
        Spiffy   => 0.18,
	GraphViz => 0,
	Graph    => 0,
	Graph::Writer    => 1.02,
    },
    dist                => {
        COMPRESS        => 'gzip -9',
        SUFFIX          => '.gz',
    },
);
