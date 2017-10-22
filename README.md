# arith

Carry Lookahead Adder in perl. Each propagate/generate group is hardcoded to 4 elements.
A 64 bit adder constist of 4 stage of propagate/generate (1 bit width, 4 bit width, 16 bit width, 64 bit width), 
3 carry generation stages (64 bit width, 16 bit width, 4 bit width) and a final sum with carry.

To test run:

`perl cla.pl`
o
