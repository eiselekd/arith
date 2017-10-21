use Data::Dumper;

@a = ([0,1],[2,3,4],[4,4]);

$r = \$a[1][2];

push(@a,[]);

$$r = 2;

print Dumper(\@a);
    
