#!/usr/bin/perl

use Test::Simple tests => 1;
use Graph::SocialMap;
use IO::All;
use YAML;

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

my $tmp = io('$');
$gsm->save(-format=> 'dot',-file=> $tmp);
$tmp->setpos(0);
my $d2 = $tmp->slurp;
my $d1;
{
    local $/ = undef;
    $d1 = <DATA>;
}
ok($d1 eq $d2);

__DATA__
graph test {
	node [label="\N"];
	graph [bb="0,0,587,609"];
	node1 [label=1234, shape=box, pos="476,265", width="0.75", height="0.50"];
	node2 [label=1357, shape=box, pos="186,266", width="0.75", height="0.50"];
	node3 [label=2468, shape=box, pos="133,566", width="0.75", height="0.50"];
	node4 [label=3579, shape=box, pos="302,182", width="0.75", height="0.50"];
	node5 [label=4680, shape=box, pos="177,19", width="0.75", height="0.50"];
	node6 [label=5555, shape=box, pos="490,519", width="0.75", height="0.50"];
	A [label=A, shape=plaintext, pos="559,539", width="0.75", height="0.50"];
	Angie [label=Angie, shape=plaintext, pos="527,316", width="0.81", height="0.50"];
	Autrijus [label=Autrijus, shape=plaintext, pos="200,361", width="1.03", height="0.50"];
	B [label=B, shape=plaintext, pos="537,573", width="0.75", height="0.50"];
	C [label=C, shape=plaintext, pos="500,590", width="0.75", height="0.50"];
	Charlee [label=Charlee, shape=plaintext, pos="425,316", width="0.94", height="0.50"];
	D [label=D, shape=plaintext, pos="460,584", width="0.75", height="0.50"];
	Dora [label=Dora, shape=plaintext, pos="425,214", width="0.75", height="0.50"];
	E [label=E, shape=plaintext, pos="429,558", width="0.75", height="0.50"];
	F [label=F, shape=plaintext, pos="418,519", width="0.75", height="0.50"];
	G [label=G, shape=plaintext, pos="429,480", width="0.75", height="0.50"];
	GGYY [label=GGYY, shape=box, pos="311,429", width="0.92", height="0.50"];
	Gugod [label=Gugod, shape=plaintext, pos="477,393", width="0.86", height="0.50"];
	H [label=H, shape=plaintext, pos="460,454", width="0.75", height="0.50"];
	I [label=I, shape=plaintext, pos="500,448", width="0.75", height="0.50"];
	J [label=J, shape=plaintext, pos="537,465", width="0.75", height="0.50"];
	Joan [label=Joan, shape=plaintext, pos="155,498", width="0.75", height="0.50"];
	K [label=K, shape=plaintext, pos="559,499", width="0.75", height="0.50"];
	Marry [label=Marry, shape=plaintext, pos="244,224", width="0.83", height="0.50"];
	OSSF [label=OSSF, shape=box, pos="28,224", width="0.75", height="0.50"];
	Peacock [label=Peacock, shape=plaintext, pos="360,139", width="0.97", height="0.50"];
	Rose [label=Rose, shape=plaintext, pos="200,87", width="0.75", height="0.50"];
	Tifa [label=Tifa, shape=plaintext, pos="527,214", width="0.75", height="0.50"];
	A -- node6 [pos="532,531 527,530 522,528 517,527"];
	Angie -- node1 [pos="509,298 504,293 499,288 494,283"];
	Autrijus -- node2 [pos="197,343 195,323 191,303 188,284"];
	Autrijus -- GGYY [pos="230,379 247,390 264,400 281,411"];
	Autrijus -- OSSF [pos="177,343 136,310 93,276 51,242"];
	B -- node6 [pos="521,555 516,549 511,543 506,537"];
	C -- node6 [pos="498,572 496,560 494,549 492,537"];
	Charlee -- node1 [pos="443,298 448,293 453,288 458,283"];
	D -- node6 [pos="468,566 473,556 477,547 482,537"];
	Dora -- node1 [pos="443,232 448,237 453,242 458,247"];
	E -- node6 [pos="456,541 458,539 461,538 463,536"];
	F -- node6 [pos="445,519 451,519 457,519 463,519"];
	G -- node6 [pos="456,497 458,499 461,500 463,502"];
	Gugod -- GGYY [pos="446,400 412,408 378,415 344,422"];
	Gugod -- OSSF [pos="446,381 316,332 185,283 55,234"];
	H -- node6 [pos="468,472 473,482 477,491 482,501"];
	I -- node6 [pos="498,466 496,478 494,489 492,501"];
	J -- node6 [pos="521,483 516,489 511,495 506,501"];
	Joan -- node3 [pos="149,516 146,527 142,537 139,548"];
	Joan -- node5 [pos="156,480 163,333 169,184 176,37"];
	Joan -- GGYY [pos="182,486 214,472 246,458 278,444"];
	K -- node6 [pos="532,507 527,508 522,510 517,511"];
	Marry -- node2 [pos="219,242 216,244 214,246 211,248"];
	Marry -- node4 [pos="269,206 272,204 274,202 277,200"];
	Peacock -- node4 [pos="336,157 333,159 329,162 326,164"];
	Peacock -- GGYY [pos="357,157 343,241 328,327 314,411"];
	Rose -- node2 [pos="199,105 195,152 191,201 187,248"];
	Rose -- node5 [pos="194,69 190,58 187,48 183,37"];
	Tifa -- node1 [pos="509,232 504,237 499,242 494,247"];
}
