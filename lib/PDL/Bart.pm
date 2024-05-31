#!perl
package PDL::Bart;


use strict;
#use PDL;
use PDL::IO::FlexRaw;
use File::Temp;
use IPC::Cmd qw/run can_run/;
use PDL::Core;
use 5.10.0;
use Exporter;
our @ISA=qw/Exporter/;
our @EXPORT_OK=qw/mapcfl writecfl readcfl bart/;

=head1 PDL::IO::Bart

Interface to the bart toolbox https://mrirecon.github.io/bart/.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

=head1 FUNCTIONS

=head2 writecfl

	writecfl(<filename>,$pdl);

=head2 readcfl

	$pdl=readcfl(<filename>);

=head2 mapcfl

	$pdl=mapcfl(<filename>);

Uses mapflex to memory-map files.

=head2 bart 

	($res1,$res2,...) = bart('cmd',[$arg1,$arg2]);

Use either file names or piddles as arguments. If piddles are used, temporary files will be created. For output, use
null() to create a placeholder. Output piddles are returned only in list context, be aware!

=cut



my $bpath; # path to bart.
my $tmp_dir; # path to temporary files.


sub writecfl {
	my $name = shift;
	my $data = shift;

	my $hdr = writeflex ($name.".cfl", cfloat($data)) || do{warn ("Cannot write to $name.cfl.\m"); return; };
	open HDR, ">$name.hdr";
	print HDR "# Dimensions\n",join ' ',$data->dims;
	print HDR "\n";
	close HDR;
}

sub mapcfl {
	my $name = shift;
	my $data;
	if ( open (HDR,"$name.hdr")) { #|| do{warn "Cannot read header $name.hdr.\n"; return ;};
	my $line;
	loop_block: {do { 
		$line = <HDR>;
		last unless (defined ($line));
	} until ($line =~/# Dimensions/);
	}
	$line = <HDR>;
	$data = mapflex ("$name.cfl",[{Dims=>[split (' ',$line)],Type=>'cfloat'}]) ;
	} else {
		my $dims=shift;
		$data = mapflex ("map_$name.cfl",[{Dims=>$dims,Type=>'cfloat'}],{Creat=>1}) ;
	}
	$data;
}


sub readcfl {
	my $name = shift;
	open (HDR,"$name.hdr") || do{warn "Cannot read header $name.hdr.\n"; return ;};
	my $line;
	loop_block: {do { 
		$line = <HDR>;
		last unless (defined ($line));
	} until ($line =~/# Dimensions/);
	}
	$line = <HDR>;
	my $data = readflex ("$name.cfl",[{Dims=>[split (' ',$line)],Type=>'cfloat'}]) ;
	$data;
}

sub bart {
	use strict;
	unless ( $bpath ) { $bpath = can_run('bart'); }
	return unless $bpath;
	my $cmd = shift;
	my $cmd_str = "$bpath $cmd ";
	my (@args,@flist,@olist);
	for my $arg (@_) {
		if ($arg->isa('PDL')) {
			my $tmp;
			if ( -d $tmp_dir) {
				$tmp=File::Temp->new(DIR=>$tmp_dir);
			} else {
				$tmp=File::Temp->new();
			}
			$cmd_str .= $tmp->filename;
			if ($arg->isnull) {
				push @olist,$arg; # save for return.
				push @flist,$tmp;
			} else {
				writecfl($tmp->filename,$arg);
			}
		} elsif ($arg=~/buffer|verbose|timeout/) {
			push @args,$arg,shift; 
		} else {
			$cmd_str .= $arg ;
		}
		$cmd_str.=' ';
		print "arg $arg;  cmd $cmd_str\n";
	}
	my @list=run(command=>$cmd_str,@args);
#	if (wantarray) {
	for my $ti (0..$#olist) {
		$olist[$ti].=readcfl($flist[$ti]->filename); # load output piddles
			unlink($flist[$ti]->filename.".hdr",$flist[$ti]->filename.".cfl");
	}
	return @olist,@list;
}

=head1 AUTHOR

Ingo Schmid, C<< <ingosch at gmx.at> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pdl-bart at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=PDL-Bart>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.





=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2024 by Ingo Schmid.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of PDL::Bart

