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

    # Generate a Graph::SocialMap object.
    my $gsm = sm(-relation => $relation) ;

    # Type 1 SocialMap (Graph::Direct object)
    my $graph_type1 = $gsm->type1;

    # Type 2 SocialMap (Graph::Direct object)
    my $graph_type2 = $gsm->type2;

    # Save it with Graph::Writer::* module
    my $writer = Graph::Writer::DGF->new();
    $writer->write_graph($graph_type1,'type1.dgf');

    # Weight of person (equal to the number of occurence)
    # Should be 2
    print $gsm->wop->{Rose};

    # Degree of seperation
    # Should be 2 (Marry -> Rose -> Joan)
    print $gsm->dos('Marry','Joan');
    # Should be less then zero (Unreachable)
    print $gsm->dos('Gugod','Marry');

    # all-pair dos (hashref of hashref)
    $gsm->all_dos;

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

use Spiffy 0.21 qw(-Base field);
use Graph;
our @EXPORT = qw(sm);
our $VERSION = '0.09';

sub paired_arguments {qw(-relation -file -format)}

field relation => {};
field issues   => [];
field people   => [];

# weight of person: number of occurences of a person in whole relation.
field wop   => {};

# under lying Graph::* object
field 'type1';
field 'type2';
field '_type3';
field 'graph_apsp';

# graphviz parameters
field layout    => 'neato';
field rank      => 'same';
field ranksep   => 1.5;
field no_overlap => 0;
field splines   => 'false';
field arrowsize => 0.5;
field fontsize  => 12;
field ordering  => 'out';
field epsilon   => 1;
field concentrate => 'true';
field ratio => 'auto';

sub sm { 
    my $new = bless {};
    $new->init($self,@_);
}

sub new {
    bless {},$self;
    $self->init(@_);
}

sub init {
    my($args,@others) = $self->parse_arguments(@_);
    $self->relation($args->{-relation});
    $self->issues([keys %{$args->{-relation}}]);
    $self->init_people;
    $self->init_graph;
    return $self;
}

sub init_people {
    my $p={};
    my $r=$self->relation;
    for(keys %$r) {
	$p->{$_}++ for @{$self->relation->{$_}};
    }
    $self->wop($p);
    $self->people([keys %$p]);
    return $self;
}

sub init_graph {
    my $rel = $self->relation;
    my $isu = $self->issues;

    my $type1 = Graph->new;
    my $type2 = Graph->new;
    my $wg = Graph->new;
    my $people = $self->people;

    $wg->add_vertices(@$people);
    for my $i (@$isu) {
	for my $e ($self->pairs(@{$rel->{$i}})) {
	    unless($wg->has_edge($e->[0],$e->[1])) {
		$wg->add_weighted_edge($e->[0],1,$e->[1]);
		$wg->add_weighted_edge($e->[1],1,$e->[0]);
	    }
	    unless($type2->has_edge($e->[0],$e->[1])) {
		$type2->add_edge($e->[0],$e->[1]);
		$type2->add_edge($e->[1],$e->[0]);
	    }
	}
    }

    for my $i (@$people) {
	my $node_name = "People/$i";
	my $label = "$i";

	$type1->add_vertex($node_name);
	$type1->set_attribute('shape',$node_name,'plaintext');
	$type1->set_attribute('label',$node_name,$label);
    }

    for my $i (@$isu) {
	my $node_name = "Relation/$i";
	my $label = "$i";

	$type1->add_vertex($node_name);
	$type1->set_attribute('shape',$node_name,'box');
	$type1->set_attribute('label',$node_name,$label);

	for my $p (@{$rel->{$i}}) {
	    $type1->add_edge("People/$p",$node_name);
	}
    }

    $self->type1($type1);
    $self->type2($type2);
    my $apsp = $wg->APSP_Floyd_Warshall;
    $self->graph_apsp($apsp);
    return $self;
}

# type3, directed people-to-people graph, in the given order
sub type3 {
    return $self->_type3 if ($self->_type3);
    my $rel = $self->relation;
    my $isu = $self->issues;
    my $type3 = Graph->new;
    my $people = $self->people;

    $type3->add_vertices(@$people);
    for my $i (@$isu) {
	my @list = @{$rel->{$i}};
	for my $i (0..$#list-1) {
	    for my $j ($i+1..$#list) {
		$type3->add_edge(@list[$j,$i])
		    unless($type3->has_edge(@list[$j,$i]));
	    }
	}
    }

    $self->_type3($type3);
    return $type3;
}

sub type3_adj_matrix {
    my $g = $self->type3;
    my @edges = $g->edges;
    my $m = {};
    while(@edges) {
	my $e1 = shift @edges;
	my $e2 = shift @edges;
	if($g->has_edge($e1,$e2)) {
	    $m->{$e1}->{$e2} = 1;
	}
    }
    return $m;
}

# Degree of seperation of two people.
sub dos {
    my ($alice,$bob) = @_;
    my $apsp = $self->graph_apsp;
    my $w = $apsp->get_attribute('weight',$alice,$bob);
    $w = -1 if(!defined $w);
    return $w;
}

# retrurn all-pair dos
sub all_dos {
    my $people = $self->people;
    my $d = {};
    for my $alice (@$people) {
	for my $bob (@$people) {
	    $d->{$alice}->{$bob} = $self->dos($alice,$bob);
	}
    }
    return $d;
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
