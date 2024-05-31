#!perl
use 5.006;
use strict;
use warnings;
use Test::Simple tests=>7;
use PDL::Bart qw/mapcfl writecfl readcfl bart/;
use PDL;

;

#BEGIN {
	my $data=xvals(8,5)+yvals(8,5);
	my $fname='test_cfl';

	writecfl($fname,$data);
	my $loaded=readcfl($fname);
	my $wrong=readcfl("xxx$fname");
	ok ($wrong==undef,'I can deal with wrong filenames.');
	ok (all($data==$loaded),'after write and read, data are the same');
	my ($new)=bart('transpose','0','1',$data, null());
	ok (all($new==$data->transpose),'Calling bart on data failed');
	$new=undef;
	$new=mapcfl($fname);
	ok (all($data==$new),'after mapcfl, data are the same');
	unlink("$fname.cfl","$fname.hdr");
	$new=mapcfl($fname,[$data->dims]);
	ok (all($data->shape==$new->shape),'after mapcfl, data are the same');
	ok ( (-f "map_$fname.cfl" ),'File was mapped.');
	$new=undef; #->DESTROY;
	warn "file exists map_$fname.cfl ?", (-f "map_$fname.cfl", "\n");
	#ok (1, 'ummy');
	unlink("map_$fname.cfl");
	ok (! (-f "map_$fname.cfl" ),'File was not removed after going out of scope.');
#}

