package Graph::SocialMap;

=head1 NAME

Graph::SocialMap - Easy tool to create social map

=head1 SYNOPSIS

    # The Structure of relationship
    my $relation = {
        1357 => [qw/Marry Rose/],
        3579 => [qw/Marry Peacock/],
        2468 => [qw/Joan/],
        4680 => [qw/Rose Joan/],
        OSSF => [qw/Gugod Autrijus/],
    };

    # Allocate a graph and then save it as png.
    my $gsm = sm(-relation => $relation) ;
    $gsm->save(-format=> 'png',-file=> '/tmp/graph.png');

    # Weight of person (equal to the number of occurence)
    # Should be 2
    print $gsm->wop->{Rose};

    # Degree of seperation
    # Should be 2 (Marry -> Rose -> Joan)
    print $gsm->dos('Marry','Joan');
    # Should be less then zero (Unreachable)
    print $gsm->dos('Gugod','Marry');

=head1 DESCRIPTION

This module implement a interesting graph application that is called
the 'Social Relation Map'. It provides object-oriented way to retrieve
many social information that can be found in this map.

This module export a method 'sm' that return a B<Graph::SocialGraph>
object. It accepts one argument in the for of 'hashref of arrayref'.
The key to this hash is the name of relation, and the value
of the hash is a list of identities involved in this relation.

Take the synopsis for an example, the structure:

    my $relation = {
        1357 => [qw/Marry Rose/],
        3579 => [qw/Marry Peacock/],
        2468 => [qw/Joan/],
        4680 => [qw/Rose Joan/],
        OSSF => [qw/Gugod Autrijus/],
    };

Defines 6 relations which have common people involves in, the relation
'1234' involves Marry and Rose, and the relation '3579' involves Marry
and Peacock. By this 2 relations, we say that Marry is directly
connected to Rose and Peacock, and Rose and Peacock are connected to
each other indirectly, with degree of seperation 1. Likewise, Marry
and Joan are connected to each other with degree of seperation 2.

=cut

use strict;
use Spiffy '-Base';
our @EXPORT = qw(sm);
our $VERSION = '0.04';
use Graph;
use Graph::Undirected;
use Graph::Writer::GraphViz;

sub paired_arguments {qw(-relation -file -format)}

field relation => {};
field issues   => [];
field people   => [];

# weight of person: number of occurences of a person in whole relation.
field wop   => {};

# under lying Graph::Undirected object
field 'graph';
field 'graph_apsp';

# graphviz parameters
field layout    => 'twopi';
field ranksep   => 1.5;
field fontsize  => 8;

sub new {
    bless [],$self;
    $self->init(@_);
    return $self;
}

spiffy_constructor 'sm';

sub init {
    my($args,@others) = $self->parse_arguments(@_);
    $self->relation($args->{-relation});
    $self->issues([keys %{$args->{-relation}}]);

    $self->init_people;
    $self->init_graph;
}

sub init_people {
    my $p={};
    my $r=$self->relation;
    for(keys %$r) {
	$p->{$_}++ for @{$self->relation->{$_}};
    }
    $self->wop($p);
    $self->people([keys %$p]);
}

sub init_graph {
    my $rel = $self->relation;
    my $isu = $self->issues;

    my $ug = Graph::Undirected->new;
    my $wg = Graph->new;
    my $people = $self->people;

    $wg->add_vertices(@$people);
    for my $i (@$isu) {
	for my $e ($self->pairs(@{$rel->{$i}})) {
	    $wg->add_weighted_edge($e->[0],1,$e->[1]);
	    $wg->add_weighted_edge($e->[1],1,$e->[0]);
	}
    }

    for my $i (@$people) {
	my $node_name = "People/$i";
	my $label = "$i";

	$ug->add_vertex($node_name);
	$ug->set_attribute('shape',$node_name,'plaintext');
	$ug->set_attribute('label',$node_name,$label);
    }

    for my $i (@$isu) {
	my $node_name = "Relation/$i";
	my $label = "$i";

	$ug->add_vertex($node_name);
	$ug->set_attribute('shape',$node_name,'box');
	$ug->set_attribute('label',$node_name,$label);

	for my $p (@{$rel->{$i}}) {
	    $ug->add_edge("People/$p",$node_name);
	}
    }

    $self->graph($ug);
    my $apsp = $wg->APSP_Floyd_Warshall;
    $self->graph_apsp($apsp);
}

# Degree of seperation of two people.
sub dos {
    my ($alice,$bob) = @_;
    my $apsp = $self->graph_apsp;
    my $w = $apsp->get_attribute('weight',$alice,$bob);
    $w = -1 if(!defined $w);
    return $w;
}

# save current graph
sub save {
    my $args = $self->parse_arguments(@_);
    my ($fmt,$file) = ($args->{'-format'}, $args->{'-file'});
    $self->save_as($fmt,$file);
}

sub save_as {
    my ($fmt,$file) = @_;
    Graph::Writer::GraphViz->new(
	-format => $fmt,
	-layout => $self->layout,
	-ranksep => $self->ranksep,
	-fontsize => $self->fontsize,
       )->write_graph(
	   $self->graph,
	   $file||'/tmp/graph.dot');
}

sub save_as_dot {
    $self->save_as('dot',shift);
}

sub save_as_png {
    $self->save_as('png',shift);
}

# return a list of all pairs.
sub pairs {
    my @list = @_;
    my @pairs;
    for my $i (0..$#list) {
	for my $j ($i+1..$#list) {
	    my ($a,$b) = @list[$i,$j];
	    push @pairs, [$a,$b];
	}
    }
    return @pairs;
}

1;

=head1 COPYRIGHT

Copyright 2004 by Kang-min Liu <gugod@gugod.org>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See <http://www.perl.com/perl/misc/Artistic.html>

=cut
