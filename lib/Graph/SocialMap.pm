package Graph::SocialMap;

=head1 NAME

Graph::SocialMap - Easy tool to create social map

=cut

use strict;
use Spiffy '-Base';
our @EXPORT = qw(sm);

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
    $self->people(keys %$p);
}

sub init_graph {
    my $rel = $self->relation;
    my $isu = $self->issues;

    my $ug = Graph::Undirected->new;
    my $wg = Graph->new;
    $ug->add_vertices($self->people);
    $wg->add_vertices($self->people);
    for my $i (@$isu) {
	for my $e ($self->pairs(@{$rel->{$i}})) {
	    $ug->add_edge(@$e);
	    $wg->add_weighted_edge($e->[0],1,$e->[1]);
	    $wg->add_weighted_edge($e->[1],1,$e->[0]);
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
    $self->save_as_png($args->{-file});
    $self->save_as_dot($args->{-file});
}

sub save_as_dot {
    Graph::Writer::GraphViz->new(-format => 'dot')->write_graph($self->graph,shift||'/tmp/graph.dot');
}

sub save_as_png {
    Graph::Writer::GraphViz->new(-format => 'png')->write_graph($self->graph,shift||'/tmp/graph.png');
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
