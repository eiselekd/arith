#!/usr/bin/perl
use bignum;

@a=();
@b=();
@s=();

$cin = 0;
@p = ();
@g = ();
@c = ();

@f = ();

for ($i = 0; $i < 64; $i++) {
    push(@a,0);
    push(@b,0);
    push(@c,0);
    push(@s,0);
    push(@p,[]);
    push(@g,[]);
}
push(@c,0);

sub _next {
    my ($i,$r) = @_;
    my $idx = scalar(@{$$r[$i]});
    push(@{$$r[$i]},0);
    return \$$r[$i][$idx];
}
sub next_g { my ($i) = @_; return _next($i,\@g);}
sub next_p { my ($i) = @_; return _next($i,\@p);}

sub _last {
    my ($i,$r) = @_;
    return \$cin if ($i < 0);
    my $idx = scalar(@{$$r[$i]})-1;
    return \$$r[$i][$idx];
}
sub last_g { my ($i) = @_; return _last($i,\@g);}
sub last_p { my ($i) = @_; return _last($i,\@p);}

sub nth_g { my ($i,$d) = @_; return \$g[$i][$d];}
sub nth_p { my ($i,$d) = @_; return \$p[$i][$d];}

sub c_pos { my ($i) = @_; return \$c[$i];}

sub digit { my ($v) = @_; return $v > 0 ? 1 : 0; }

# generate first stage propagate and generate
sub gen_pg_0 {
    my ($i) = @_; 
    my $a0 = \$a[$i];
    my $b0 = \$b[$i];
    my $g0 = next_g($i);
    my $p0 = next_p($i);
    
    push(@f,sub {
	$$g0 = $$a0 & $$b0;
	$$p0 = $$a0 | $$b0;
	 });
}    

for ($i = 0; $i < 64; $i++) {
    gen_pg_0($i);
}


# combine propagate and generate in blocks
sub gen_pg {
    
    my ($i,$l) = @_; 
    my $g0 = last_g($i+1*$l-1);
    my $g1 = last_g($i+2*$l-1);
    my $g2 = last_g($i+3*$l-1);
    my $g3 = last_g($i+4*$l-1);
    
    my $p0 = last_p($i+1*$l-1);
    my $p1 = last_p($i+2*$l-1);
    my $p2 = last_p($i+3*$l-1);
    my $p3 = last_p($i+4*$l-1);
    
    my $g = next_g($i+4*$l-1);
    my $p = next_p($i+4*$l-1);
    
    push(@f,sub {
	$$g = digit($$g3+($$g2*$$p3)+($$g1*$$p2*$$p3)+($$g0*$$p1*$$p2*$$p3));
	$$p = digit($$p0*$$p1*$$p2*$$p3);
	return ($$p,$$g);
	 });
}

# blocks of 4
for ($i = 0; $i < 64/4; $i++) {
    gen_pg($i*4,1);
}
# blocks of 16
for ($i = 0; $i < 64/16; $i++) {
    gen_pg($i*16,4);
}
# blocks of 64
for ($i = 0; $i < 64/64; $i++) {
    gen_pg($i*64,16);
}

sub gen_c {
    my ($i,$l,$d,$docout) = @_; 
    my $g0 = nth_g($i+1*$l-1,$d);
    my $g1 = nth_g($i+2*$l-1,$d);
    my $g2 = nth_g($i+3*$l-1,$d);
    my $g3 = nth_g($i+4*$l-1,$d);
    
    my $p0 = nth_p($i+1*$l-1,$d);
    my $p1 = nth_p($i+2*$l-1,$d);
    my $p2 = nth_p($i+3*$l-1,$d);
    my $p3 = nth_p($i+4*$l-1,$d);

    my $gin =  c_pos($i);
    
    my $c1  =  c_pos($i+1*$l);
    my $c2  =  c_pos($i+2*$l);
    my $c3  =  c_pos($i+3*$l);
    my $c4  =  c_pos($i+4*$l);
    
    push(@f,sub {
	
	$$c1   = digit($$gin*$$p0                +$$g0);
	$$c2   = digit($$gin*$$p0*$$p1           +$$g0*$$p1      + $$g1);
	$$c3   = digit($$gin*$$p0*$$p1*$$p2      +$$g0*$$p1*$$p2 + $$g1*$$p2 + $$g2);
	if ($docout) {
	    $$c4   = digit($$gin*$$p0*$$p1*$$p2*$$p3      +$$g0*$$p1*$$p2*$$p3 + $$g1*$$p2*$$p3 + $$g2*$$p3 + $$g3);
	}

	 });
}



# define 3 carries
for ($i = 0; $i < 64/64; $i++) {
    gen_c($i*64,16,2,1);
}

# define 3*4 carries
for ($i = 0; $i < 64/16; $i++) {
    gen_c($i*16,4,1,0);
}

# define 3*16 carries
for ($i = 0; $i < 64/4; $i++) {
    gen_c($i*4,1,0,0);
}

# generate final sum
sub gen_sum_0 {
    my ($i) = @_; 
    my $a0 = \$a[$i];
    my $b0 = \$b[$i];
    my $c0 = c_pos($i);
    my $s0 = \$s[$i];
    push(@f,sub {
	$$s0 = ($$a0 + $$b0 + $$c0) & 1;
	 });
}    

for ($i = 0; $i < 64; $i++) {
    gen_sum_0($i);
}



# test cla adder
sub test_sum {
    my ($a,$b,$cin) = @_;
    
    for (my $i = 0; $i < 64; $i++) {
	$a[$i] = ($a & (1<<$i)) ? 1 : 0;
	$b[$i] = ($b & (1<<$i)) ? 1 : 0;
    }
    print(" |".join("",@a));
    print("\n");
    print("+|".join("",@b));
    print(" cin:$cin\n");
    $c[0] = $cin;
    
    foreach my $f (@f) {
	$f->();
    }

    print("= ".join("",@s));
    print("\n");

    my $sum = 0;
    for (my $i = 0; $i < 64; $i++) {
	$sum |= ($s[$i] << $i);
    }
    
    printf("sum: 0x%x : cout:%d\n", $sum, $c[64]);
    return ($sum,$c[64]);
}

while (1) {
    $a = (int(rand(0x7fffffffffffffff)) ^ rand(0x7fffffff)) & 0xffffffffffffffff;
    $b = (int(rand(0x7fffffffffffffff)) ^ rand(0x7fffffff)) & 0xffffffffffffffff;
    $cin = int(rand(2));
    
    my ($sum,$cout) = test_sum($a, $b, $cin);
    
    my $mysum  = ($a + $b + $cin) & 0xffffffffffffffff;
    my $mycout = (($a + $b + $cin) & 0x10000000000000000) ? 1 : 0;
    if ($mysum != $sum || $mycout != $cout) {
	printf("Error expect 0x%x:%d got 0x%x:%d\n", $mysum, $mycout, $sum, $cout);
	die("Error\n");
    } 
}

