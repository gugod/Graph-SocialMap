#!/usr/bin/perl
use strict;
use warnings;
use Test::Simple tests => 10;
use Graph::SocialMap;
use Graph::Writer::GraphViz;
use IO::All;

my $relation = {
    1357 => [qw/Marry Rose Autrijus/],
    3579 => [qw/Marry Peacock/],
    2468 => [qw/Joan/],
    4680 => [qw/Rose Joan/],
    OSSF => [qw/Gugod Autrijus/],
    GGYY => [qw/Gugod Autrijus Joan Peacock/],
    1234 => [qw/Tifa Dora Charlee Angie/],
    5555 => [qw/A B C D E F G H I J K/],
};

my $gsm = sm(-relation => $relation);
my $writer = Graph::Writer::GraphViz->new(-format=>'dot');
$writer->write_graph($gsm->type3,'t/graphtest2.dot');

my $tmp = io('t/graphtest2.dot');
my $d2 = $tmp->slurp;
my $d1;
{
    local $/ = undef;
    $d1 = <DATA>;
}
ok($d1 eq $d2);
$tmp->unlink;

my $adjm = $gsm->type3_adj_matrix;
ok($adjm->{Rose}->{Marry} == 1);

ok(cmp_hashes($adjm->{Angie},{Tifa=>1,Dora=>1,Charlee=>1}));
ok(cmp_hashes($adjm->{Charlee},{Tifa=>1,Dora=>1}));
ok(cmp_hashes($adjm->{Dora},{Tifa=>1}));
ok(cmp_hashes($adjm->{Marry},{}));
ok(cmp_hashes($adjm->{Gugod},{}));
ok(cmp_hashes($adjm->{Joan},{Rose => 1, Gugod => 1, Autrijus => 1}));
ok(cmp_hashes($adjm->{Autrijus},{Marry=>1,Rose=>1,Gugod=>1}));
ok(cmp_hashes($adjm->{Peacock} ,{Marry=>1,Gugod=>1,Autrijus=>1,Joan=>1}));

sub cmp_hashes {
    my ($h1,$h2) = @_;
    return 0 unless (keys %$h1 == keys %$h2);
    for (keys %$h1) {
	return 0 if($h1->{$_} ne $h2->{$_});
    }
    return 1;
}

__DATA__
digraph test {
	graph [ratio=fill];
	node [label="\N", color=black];
	edge [color=black];
	graph [bb="0,0,4966,124"];
	A [label=A, pos="27,98", width="0.75", height="0.50"];
	Tifa [label=Tifa, pos="99,98", width="0.75", height="0.50"];
	Joan [label=Joan, pos="173,98", width="0.81", height="0.50"];
	F [label=F, pos="247,98", width="0.75", height="0.50"];
	Gugod [label=Gugod, pos="328,98", width="1.00", height="0.50"];
	D [label=D, pos="409,98", width="0.75", height="0.50"];
	Dora [label=Dora, pos="484,98", width="0.83", height="0.50"];
	H [label=H, pos="559,98", width="0.75", height="0.50"];
	J [label=J, pos="631,98", width="0.75", height="0.50"];
	E [label=E, pos="703,98", width="0.75", height="0.50"];
	Autrijus [label=Autrijus, pos="790,98", width="1.17", height="0.50"];
	C [label=C, pos="877,98", width="0.75", height="0.50"];
	Marry [label=Marry, pos="957,98", width="0.97", height="0.50"];
	G [label=G, pos="1037,98", width="0.75", height="0.50"];
	Peacock [label=Peacock, pos="1122,98", width="1.11", height="0.50"];
	B [label=B, pos="1207,98", width="0.75", height="0.50"];
	Rose [label=Rose, pos="1281,98", width="0.81", height="0.50"];
	Angie [label=Angie, pos="1362,98", width="0.94", height="0.50"];
	I [label=I, pos="1441,98", width="0.75", height="0.50"];
	Charlee [label=Charlee, pos="1525,98", width="1.08", height="0.50"];
	K [label=K, pos="1609,98", width="0.75", height="0.50"];
	node1 [label="<port0>F|<port1>D", shape=record, pos="1681,98", rects="1654,80,1679,116 1679,80,1708,116", width="0.75", height="0.50"];
	node2 [label="<port0>E|<port1>D", shape=record, pos="1681,26", rects="1654,8,1680,44 1680,8,1708,44", width="0.75", height="0.50"];
	node3 [label="<port0>Angie|<port1>Tifa", shape=record, pos="1769,98", rects="1726,80,1776,116 1776,80,1813,116", width="1.19", height="0.50"];
	node4 [label="<port0>I|<port1>B", shape=record, pos="1769,26", rects="1742,8,1766,44 1766,8,1796,44", width="0.75", height="0.50"];
	node5 [label="<port0>Peacock|<port1>Joan", shape=record, pos="1881,98", rects="1830,80,1893,116 1893,80,1933,116", width="1.42", height="0.50"];
	node6 [label="<port0>D|<port1>A", shape=record, pos="1881,26", rects="1854,8,1880,44 1880,8,1908,44", width="0.75", height="0.50"];
	node7 [label="<port0>F|<port1>C", shape=record, pos="1977,98", rects="1950,80,1976,116 1976,80,2004,116", width="0.75", height="0.50"];
	node8 [label="<port0>F|<port1>B", shape=record, pos="1977,26", rects="1950,8,1976,44 1976,8,2004,44", width="0.75", height="0.50"];
	node9 [label="<port0>D|<port1>B", shape=record, pos="2049,98", rects="2022,80,2049,116 2049,80,2076,116", width="0.75", height="0.50"];
	node10 [label="<port0>K|<port1>E", shape=record, pos="2049,26", rects="2022,8,2050,44 2050,8,2076,44", width="0.75", height="0.50"];
	node11 [label="<port0>J|<port1>H", shape=record, pos="2121,98", rects="2094,80,2118,116 2118,80,2148,116", width="0.75", height="0.50"];
	node12 [label="<port0>G|<port1>C", shape=record, pos="2121,26", rects="2094,8,2121,44 2121,8,2148,44", width="0.75", height="0.50"];
	node13 [label="<port0>J|<port1>I", shape=record, pos="2205,98", rects="2178,80,2205,116 2205,80,2232,116", width="0.75", height="0.50"];
	node14 [label="<port0>Dora|<port1>Tifa", shape=record, pos="2205,26", rects="2166,8,2208,44 2208,8,2245,44", width="1.08", height="0.50"];
	node15 [label="<port0>H|<port1>B", shape=record, pos="2289,98", rects="2262,80,2289,116 2289,80,2316,116", width="0.75", height="0.50"];
	node16 [label="<port0>G|<port1>A", shape=record, pos="2289,26", rects="2262,8,2288,44 2288,8,2316,44", width="0.75", height="0.50"];
	node17 [label="<port0>K|<port1>C", shape=record, pos="2361,98", rects="2334,80,2362,116 2362,80,2388,116", width="0.75", height="0.50"];
	node18 [label="<port0>H|<port1>D", shape=record, pos="2361,26", rects="2334,8,2361,44 2361,8,2388,44", width="0.75", height="0.50"];
	node19 [label="<port0>H|<port1>A", shape=record, pos="2433,98", rects="2406,80,2432,116 2432,80,2460,116", width="0.75", height="0.50"];
	node20 [label="<port0>J|<port1>F", shape=record, pos="2433,26", rects="2406,8,2431,44 2431,8,2460,44", width="0.75", height="0.50"];
	node21 [label="<port0>Angie|<port1>Dora", shape=record, pos="2524,98", rects="2478,80,2528,116 2528,80,2570,116", width="1.28", height="0.50"];
	node22 [label="<port0>I|<port1>C", shape=record, pos="2524,26", rects="2497,8,2521,44 2521,8,2551,44", width="0.75", height="0.50"];
	node23 [label="<port0>H|<port1>G", shape=record, pos="2615,98", rects="2588,80,2615,116 2615,80,2642,116", width="0.75", height="0.50"];
	node24 [label="<port0>F|<port1>E", shape=record, pos="2615,26", rects="2588,8,2614,44 2614,8,2642,44", width="0.75", height="0.50"];
	node25 [label="<port0>Charlee|<port1>Dora", shape=record, pos="2711,98", rects="2660,80,2720,116 2720,80,2762,116", width="1.42", height="0.50"];
	node26 [label="<port0>K|<port1>I", shape=record, pos="2711,26", rects="2684,8,2715,44 2715,8,2738,44", width="0.75", height="0.50"];
	node27 [label="<port0>H|<port1>E", shape=record, pos="2807,98", rects="2780,80,2808,116 2808,80,2834,116", width="0.75", height="0.50"];
	node28 [label="<port0>I|<port1>A", shape=record, pos="2807,26", rects="2780,8,2803,44 2803,8,2834,44", width="0.75", height="0.50"];
	node29 [label="<port0>C|<port1>B", shape=record, pos="2879,98", rects="2852,80,2879,116 2879,80,2906,116", width="0.75", height="0.50"];
	node30 [label="<port0>J|<port1>G", shape=record, pos="2879,26", rects="2852,8,2876,44 2876,8,2906,44", width="0.75", height="0.50"];
	node31 [label="<port0>Autrijus|<port1>Gugod", shape=record, pos="2984,98", rects="2924,80,2990,116 2990,80,3045,116", width="1.67", height="0.50"];
	node32 [label="<port0>K|<port1>H", shape=record, pos="2984,26", rects="2957,8,2984,44 2984,8,3011,44", width="0.75", height="0.50"];
	node33 [label="<port0>Angie|<port1>Charlee", shape=record, pos="3117,98", rects="3062,80,3112,116 3112,80,3172,116", width="1.53", height="0.50"];
	node34 [label="<port0>G|<port1>F", shape=record, pos="3117,26", rects="3090,8,3118,44 3118,8,3144,44", width="0.75", height="0.50"];
	node35 [label="<port0>G|<port1>B", shape=record, pos="3217,98", rects="3190,80,3217,116 3217,80,3244,116", width="0.75", height="0.50"];
	node36 [label="<port0>Charlee|<port1>Tifa", shape=record, pos="3217,26", rects="3169,8,3229,44 3229,8,3266,44", width="1.33", height="0.50"];
	node37 [label="<port0>I|<port1>H", shape=record, pos="3330,98", rects="3303,80,3326,116 3326,80,3357,116", width="0.75", height="0.50"];
	node38 [label="<port0>Joan|<port1>Gugod", shape=record, pos="3330,26", rects="3283,8,3323,44 3323,8,3378,44", width="1.31", height="0.50"];
	node39 [label="<port0>Peacock|<port1>Autrijus", shape=record, pos="3454,98", rects="3390,80,3453,116 3453,80,3519,116", width="1.78", height="0.50"];
	node40 [label="<port0>Peacock|<port1>Gugod", shape=record, pos="3454,26", rects="3395,8,3458,44 3458,8,3513,44", width="1.64", height="0.50"];
	node41 [label="<port0>Rose|<port1>Marry", shape=record, pos="3583,98", rects="3536,80,3577,116 3577,80,3630,116", width="1.31", height="0.50"];
	node42 [label="<port0>E|<port1>B", shape=record, pos="3583,26", rects="3556,8,3582,44 3582,8,3610,44", width="0.75", height="0.50"];
	node43 [label="<port0>Peacock|<port1>Marry", shape=record, pos="3706,98", rects="3648,80,3711,116 3711,80,3764,116", width="1.61", height="0.50"];
	node44 [label="<port0>J|<port1>C", shape=record, pos="3706,26", rects="3679,8,3703,44 3703,8,3733,44", width="0.75", height="0.50"];
	node45 [label="<port0>E|<port1>C", shape=record, pos="3809,98", rects="3782,80,3808,116 3808,80,3836,116", width="0.75", height="0.50"];
	node46 [label="<port0>H|<port1>C", shape=record, pos="3809,26", rects="3782,8,3809,44 3809,8,3836,44", width="0.75", height="0.50"];
	node47 [label="<port0>G|<port1>E", shape=record, pos="3881,98", rects="3854,80,3882,116 3882,80,3908,116", width="0.75", height="0.50"];
	node48 [label="<port0>K|<port1>A", shape=record, pos="3881,26", rects="3854,8,3881,44 3881,8,3908,44", width="0.75", height="0.50"];
	node49 [label="<port0>Joan|<port1>Autrijus", shape=record, pos="3979,98", rects="3926,80,3966,116 3966,80,4032,116", width="1.47", height="0.50"];
	node50 [label="<port0>K|<port1>J", shape=record, pos="3979,26", rects="3952,8,3982,44 3982,8,4006,44", width="0.75", height="0.50"];
	node51 [label="<port0>K|<port1>F", shape=record, pos="4077,98", rects="4050,80,4079,116 4079,80,4104,116", width="0.75", height="0.50"];
	node52 [label="<port0>D|<port1>C", shape=record, pos="4077,26", rects="4050,8,4077,44 4077,8,4104,44", width="0.75", height="0.50"];
	node53 [label="<port0>K|<port1>G", shape=record, pos="4149,98", rects="4122,80,4149,116 4149,80,4176,116", width="0.75", height="0.50"];
	node54 [label="<port0>J|<port1>B", shape=record, pos="4149,26", rects="4122,8,4146,44 4146,8,4176,44", width="0.75", height="0.50"];
	node55 [label="<port0>I|<port1>E", shape=record, pos="4234,98", rects="4207,80,4231,116 4231,80,4261,116", width="0.75", height="0.50"];
	node56 [label="<port0>Joan|<port1>Rose", shape=record, pos="4234,26", rects="4194,8,4234,44 4234,8,4275,44", width="1.11", height="0.50"];
	node57 [label="<port0>H|<port1>F", shape=record, pos="4319,98", rects="4292,80,4320,116 4320,80,4346,116", width="0.75", height="0.50"];
	node58 [label="<port0>K|<port1>B", shape=record, pos="4319,26", rects="4292,8,4320,44 4320,8,4346,44", width="0.75", height="0.50"];
	node59 [label="<port0>J|<port1>A", shape=record, pos="4391,98", rects="4364,80,4387,116 4387,80,4418,116", width="0.75", height="0.50"];
	node60 [label="<port0>C|<port1>A", shape=record, pos="4391,26", rects="4364,8,4390,44 4390,8,4418,44", width="0.75", height="0.50"];
	node61 [label="<port0>Autrijus|<port1>Marry", shape=record, pos="4495,98", rects="4436,80,4502,116 4502,80,4555,116", width="1.64", height="0.50"];
	node62 [label="<port0>I|<port1>D", shape=record, pos="4495,26", rects="4468,8,4491,44 4491,8,4522,44", width="0.75", height="0.50"];
	node63 [label="<port0>F|<port1>A", shape=record, pos="4599,98", rects="4572,80,4597,116 4597,80,4626,116", width="0.75", height="0.50"];
	node64 [label="<port0>I|<port1>G", shape=record, pos="4599,26", rects="4572,8,4595,44 4595,8,4626,44", width="0.75", height="0.50"];
	node65 [label="<port0>I|<port1>F", shape=record, pos="4671,98", rects="4644,80,4669,116 4669,80,4698,116", width="0.75", height="0.50"];
	node66 [label="<port0>E|<port1>A", shape=record, pos="4671,26", rects="4644,8,4669,44 4669,8,4698,44", width="0.75", height="0.50"];
	node67 [label="<port0>K|<port1>D", shape=record, pos="4769,98", rects="4742,80,4769,116 4769,80,4796,116", width="0.75", height="0.50"];
	node68 [label="<port0>Autrijus|<port1>Rose", shape=record, pos="4769,26", rects="4716,8,4782,44 4782,8,4823,44", width="1.47", height="0.50"];
	node69 [label="<port0>G|<port1>D", shape=record, pos="4867,98", rects="4840,80,4867,116 4867,80,4894,116", width="0.75", height="0.50"];
	node70 [label="<port0>J|<port1>D", shape=record, pos="4867,26", rects="4840,8,4864,44 4864,8,4894,44", width="0.75", height="0.50"];
	node71 [label="<port0>J|<port1>E", shape=record, pos="4939,98", rects="4912,80,4937,116 4937,80,4966,116", width="0.75", height="0.50"];
	node72 [label="<port0>B|<port1>A", shape=record, pos="4939,26", rects="4912,8,4938,44 4938,8,4966,44", width="0.75", height="0.50"];
	node3 -> node4 [pos="e,1769,44 1769,80 1769,72 1769,63 1769,54"];
	node1 -> node2 [pos="e,1681,44 1681,80 1681,72 1681,63 1681,54"];
	node5 -> node6 [pos="e,1881,44 1881,80 1881,72 1881,63 1881,54"];
	node7 -> node8 [pos="e,1977,44 1977,80 1977,72 1977,63 1977,54"];
	node9 -> node10 [pos="e,2049,44 2049,80 2049,72 2049,63 2049,54"];
	node11 -> node12 [pos="e,2121,44 2121,80 2121,72 2121,63 2121,54"];
	node13 -> node14 [pos="e,2205,44 2205,80 2205,72 2205,63 2205,54"];
	node15 -> node16 [pos="e,2289,44 2289,80 2289,72 2289,63 2289,54"];
	node17 -> node18 [pos="e,2361,44 2361,80 2361,72 2361,63 2361,54"];
	node19 -> node20 [pos="e,2433,44 2433,80 2433,72 2433,63 2433,54"];
	node21 -> node22 [pos="e,2524,44 2524,80 2524,72 2524,63 2524,54"];
	node23 -> node24 [pos="e,2615,44 2615,80 2615,72 2615,63 2615,54"];
	node25 -> node26 [pos="e,2711,44 2711,80 2711,72 2711,63 2711,54"];
	node27 -> node28 [pos="e,2807,44 2807,80 2807,72 2807,63 2807,54"];
	node29 -> node30 [pos="e,2879,44 2879,80 2879,72 2879,63 2879,54"];
	node31 -> node32 [pos="e,2984,44 2984,80 2984,72 2984,63 2984,54"];
	node33 -> node34 [pos="e,3117,44 3117,80 3117,72 3117,63 3117,54"];
	node35 -> node36 [pos="e,3217,44 3217,80 3217,72 3217,63 3217,54"];
	node37 -> node38 [pos="e,3330,44 3330,80 3330,72 3330,63 3330,54"];
	node39 -> node40 [pos="e,3454,44 3454,80 3454,72 3454,63 3454,54"];
	node41 -> node42 [pos="e,3583,44 3583,80 3583,72 3583,63 3583,54"];
	node43 -> node44 [pos="e,3706,44 3706,80 3706,72 3706,63 3706,54"];
	node45 -> node46 [pos="e,3809,44 3809,80 3809,72 3809,63 3809,54"];
	node47 -> node48 [pos="e,3881,44 3881,80 3881,72 3881,63 3881,54"];
	node49 -> node50 [pos="e,3979,44 3979,80 3979,72 3979,63 3979,54"];
	node51 -> node52 [pos="e,4077,44 4077,80 4077,72 4077,63 4077,54"];
	node53 -> node54 [pos="e,4149,44 4149,80 4149,72 4149,63 4149,54"];
	node55 -> node56 [pos="e,4234,44 4234,80 4234,72 4234,63 4234,54"];
	node57 -> node58 [pos="e,4319,44 4319,80 4319,72 4319,63 4319,54"];
	node59 -> node60 [pos="e,4391,44 4391,80 4391,72 4391,63 4391,54"];
	node61 -> node62 [pos="e,4495,44 4495,80 4495,72 4495,63 4495,54"];
	node63 -> node64 [pos="e,4599,44 4599,80 4599,72 4599,63 4599,54"];
	node65 -> node66 [pos="e,4671,44 4671,80 4671,72 4671,63 4671,54"];
	node67 -> node68 [pos="e,4769,44 4769,80 4769,72 4769,63 4769,54"];
	node69 -> node70 [pos="e,4867,44 4867,80 4867,72 4867,63 4867,54"];
	node71 -> node72 [pos="e,4939,44 4939,80 4939,72 4939,63 4939,54"];
}
