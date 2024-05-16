#!perl
use 5.006;
use strict;
use warnings;
use Test::Simple tests=>2;
use PDL::Bart qw/writecfl readcfl bart/;
use PDL;

;

BEGIN {
	my $data=xvals(8,5)+yvals(8,5);
	my $fname='test_cfl';

	writecfl($fname,$data);
	my $loaded=readcfl($fname);
	ok (all($data==$loaded),'after write and read, data are the same');
	my ($new)=bart('transpose','0','1',$data, null());
	ok (all($new==$data->transpose),'Calling bart on data failed');
	unlink("$fname.cfl","$fname.hdr");
}

