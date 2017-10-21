#!/usr/bin/perl

@a=(0 x 64);
@b=(0 x 64);
$cin = 0;
@p = ([] x 64);
@g = ([] x 64);
@g = ([] x 64);
@c = ([] x 64);
@f = ();

sub _next($i,$r) {
    my $idx = scalar($$r[$i]);
    push(@{$$r[$i]},0);
    return \$$r[$i][$idx];
}

sub next_g($i) { return _next($i,\@g);}
sub next_p($i) { return _next($i,\@p);}
sub next_c($i) { return _next($i,\@c);}

sub first_c($i) {
    return \$cin if ($i < 0);
    return \$c[$i][0]
}

sub digit($v) { return $v > 0 ? 1 : 0; }

# generate first stage propagate and generate
sub gen_pg_0($i) {
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
sub gen_pg($i,$l) {
    my $g0 = last_g($i+0*$l);
    my $g1 = last_g($i+1*$l);
    my $g2 = last_g($i+2*$l);
    my $g3 = last_g($i+3*$l);
    my $p0 = last_p($i+0*$l);
    my $p1 = last_p($i+1*$l);
    my $p2 = last_p($i+2*$l);
    my $p3 = last_p($i+3*$l);
    my $g = next_g($i);
    my $p = next_p($i);
    
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

sub gen_c($i,$l) {
    my $g0 = last_g($i+0*$l);
    my $g1 = last_g($i+1*$l);
    my $g2 = last_g($i+2*$l);
    my $g3 = last_g($i+3*$l);
    
    my $p0 = last_p($i+0*$l);
    my $p1 = last_p($i+1*$l);
    my $p2 = last_p($i+2*$l);
    my $p3 = last_p($i+3*$l);

    my $cin0 = first_c($i+0*$l-1);
    my $c0   =  next_c($i+1*$l-1);
    my $c1   =  next_c($i+2*$l-1);
    my $c2   =  next_c($i+3*$l-1);
    my $c3   =  next_c($i+4*$l-1);
    
    push(@f,sub {

       #$$c0   = digit($$cin0);
	$$c1   = digit($$cin0*$$p0           +$$g0);
	$$c2   = digit($$cin0*$$p0*$$p1      +$$g0*$$p0      + $$g1);
	$$c3   = digit($$cin0*$$p0*$$p1*$$p2 +$$g0*$$p1*$$p2 + $$g1*$$p2 + $$g2);
	
	 });
}

# define 3 carries
for ($i = 0; $i < 64/64; $i++) {
    gen_c($i*64,16);
}

# define 3*4 carries
for ($i = 0; $i < 64/16; $i++) {
    gen_c($i*16,4);
}

# define 3*16 carries
for ($i = 0; $i < 64/4; $i++) {
    gen_c($i*4,1);
}

# generate final sum
sub gen_sum_0($i) {
    my $a0 = \$a[$i];
    my $b0 = \$b[$i];
    my $s0 = \$b[$i];
    my $c0 = first_c($i-1);
    push(@f,sub {
	$$s0 = digit($$a0 + $$b0 + $c0);
	 });
}    

for ($i = 0; $i < 64; $i++) {
    gen_sum_0($i);
}




foreach my $f (@f) {
    $$f();
}


