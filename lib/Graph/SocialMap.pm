package Graph::SocialMap;
use Spiffy 0.21 qw(-Base field);
use Graph 0.54;
our @EXPORT = qw(sm);
our $VERSION = '0.10';

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
    my $people = $self->people;

    for my $i (@$isu) {
	for my $e ($self->pairs(@{$rel->{$i}})) {
	    unless($type2->has_edge($e->[0],$e->[1])) {
		$type2->add_edge($e->[0],$e->[1]);
		$type2->add_edge($e->[1],$e->[0]);
	    }
	}
    }

    my $apsp = $type2->APSP_Floyd_Warshall;
    $self->graph_apsp($apsp);

    for my $i (@$people) {
	my $node_name = "People/$i";
	my $label = "$i";

	$type1->add_vertex($node_name);
        $type1->set_vertex_attribute($node_name,shape => 'plaintext');
        $type1->set_vertex_attribute($node_name,label => $label);
    }

    for my $i (@$isu) {
	my $node_name = "Relation/$i";
	my $label = "$i";

	$type1->add_vertex($node_name);
        $type1->set_vertex_attribute($node_name, shape => "box");
        $type1->set_vertex_attribute($node_name, label => $label);

	for my $p (@{$rel->{$i}}) {
	    $type1->add_edge("People/$p",$node_name);
	}
    }

    $self->type1($type1);
    $self->type2($type2);
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
    my $m = {};
    for($self->type3->edges) {
        $m->{$_->[0]}->{$_->[1]} = 1;
    }
    return $m;
}

# Degree of seperation of two people.
sub dos {
    my ($alice,$bob) = @_;
    my $apsp = $self->graph_apsp;
    my $w = $apsp->path_length($alice,$bob);
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

