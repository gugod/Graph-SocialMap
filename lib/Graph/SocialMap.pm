package Graph::SocialMap;
use Spiffy 0.21 qw(-Base field);
use Graph 0.54;
our $VERSION = '0.11';

sub paired_arguments {qw(-relation -file -format)}

# Cached fields
field '_relation';
field '_issues';
field '_people';

# weight of person: number of occurences of a person in whole relation.
field '_wop';

# under lying Graph::* object
field '_type1';
field '_type2';
field '_type3';
field '_apsp';

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

sub relation {
    my $newval = shift;
    if($newval) {
        $self->_relation($newval);
        $self->_people(undef);
        $self->_issues(undef);
        $self->_type1(undef);
        $self->_type2(undef);
        $self->_type3(undef);
        $self->_apsp(undef);
    }
    return $self->_relation;
}

sub issues {
    return $self->_issues if $self->_issues;
    my $issues = [keys %{$self->relation}];
    $self->_issues($issues);
    return $issues;
}

sub people {
    return $self->_people if ($self->_people);
    my $p={};
    my $r=$self->relation;
    for(keys %$r) {
	$p->{$_}++ for @{$r->{$_}};
    }
    $self->_wop($p);
    my $people = [keys %$p];
    $self->_people($people);
    return $people;
}

sub wop {
    return $self->_wop if $self->_wop;
    $self->people;
    $self->_wop;
}

sub type2 {
    return $self->_type2 if ($self->_type2);
    my $isu = $self->issues;
    my $rel = $self->relation;
    my $type2 = Graph->new;

    for my $i (@$isu) {
	for my $e ($self->pairs(@{$rel->{$i}})) {
	    unless($type2->has_edge($e->[0],$e->[1])) {
		$type2->add_edge($e->[0],$e->[1]);
		$type2->add_edge($e->[1],$e->[0]);
	    }
	}
    }
    $self->_type2($type2);
    return $type2;
}

sub apsp {
    return $self->_apsp if($self->_apsp);
    my $a = $self->type2->APSP_Floyd_Warshall;
    $self->_apsp($a);
    return $a;
}

sub type1 {
    return $self->_type1 if ($self->_type1);
    my $type1 = Graph->new;
    my $people = $self->people;
    my $isu = $self->issues;
    my $rel = $self->relation;

    for my $i (@$people) {
	my $node_name = "People/$i";
	my $label = "$i";

	$type1->add_vertex($node_name);
        $type1->set_vertex_attribute($node_name,shape => 'plaintext');
        $type1->set_vertex_attribute($node_name,label => $label);
    }

    for my $i (@$isu) {
	my $node_name = "Relation $i";
	my $label = "$i";

	$type1->add_vertex($node_name);
        $type1->set_vertex_attribute($node_name, shape => "box");
        $type1->set_vertex_attribute($node_name, label => $label);

	for my $p (@{$rel->{$i}}) {
	    $type1->add_edge("People $p",$node_name);
	}
    }

    $self->_type1($type1);
    return $type1;
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
    my $apsp = $self->apsp;
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

