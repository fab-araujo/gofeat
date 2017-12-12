#!/usr/bin/perl

#
# Simple web server for the mac app.
# Original version courtesy one of the folks at perlmonks.org, hacked
# to fork the cgi instead of running inline and for serving up
# static files.
#

# This is a SAS component.

use strict;
use warnings;
use IO::Socket::INET;
use IO::String;
use IO::Pipe;

my $sgv = "sgv.cgi";

if ($ENV{SAS_HOME})
{
    $sgv  = "$ENV{SAS_HOME}/bin/sgv.cgi";
    $ENV{PATH} .= ":$ENV{SAS_HOME}/bin";
}

my %type_map = (jpg => 'image/jpeg',
		jpeg => 'image/jpeg',
		png => 'image/png',
		gif => 'image/gif',
		html => 'text/html',
		txt  => 'text/plain');

my $tmpdir = "/tmp";

my $port = shift(@ARGV) || 9000;
my $listen = IO::Socket::INET->new(
				   Listen    => 5,
				   LocalAddr => 'localhost',
				   LocalPort => $port,
				   Proto     => 'tcp',
				   ReuseAddr => 1
				  );

unless ($listen) {
    die "unable to listen on port $port: $!\n"
    };

$ENV{SERVER_NAME} = "localhost";
$ENV{SERVER_PORT} = $port;
$ENV{SERVER_SOFTWARE} = "exec-cgi.pl/1.0";

while (1) {
    print STDERR "waiting for connection on port $port\n";
    my $s = $listen->accept();
    
    my ($req, $content);
    delete $ENV{CONTENT_LENGTH};
    {
	local ($/) = "\r\n";
	while (<$s>) {
	    $req .= $_;
	    chomp;
	    # print STDERR "got: $_\n";
	    last unless /\S/;
	    if (/^GET\s*(\S+)/) {
		$ENV{REQUEST_METHOD} = 'GET';
		(my $qs = $1) =~ m/\?(.*)/;
		$ENV{'QUERY_STRING'} = $1;
	    } elsif (/^POST/) {
		$ENV{REQUEST_METHOD} = 'POST';
		$ENV{'QUERY_STRING'} = '';
	    } elsif (/^Content-Type:\s*(.*)/) {
		$ENV{CONTENT_TYPE} = $1;
	    } elsif (/^Content-Length:\s*(.*)/) {
		$ENV{CONTENT_LENGTH} = $1;
	    }
	}
    }
    $content = '';
    if (my $size = $ENV{CONTENT_LENGTH}) {
	while (length($content) < $size) {
	    my $nr = read($s, $content, $size-length($content),
			  length($content));
	    die "read error" unless $nr;
	}
    }
    
    #
    # Wow this is a hack. Personalized HTTP server for SEED.
    #
    
    if ($ENV{QUERY_STRING} =~ m,FIG-Tmp/(.*)$,)
    {
	my $path = "$tmpdir/$1";
	print "For query $ENV{QUERY_STRING} opening $path\n";
	if (!open(TMP, "<", $path))
	{
	    warn "Error opening $path: $!\n";
	    print $s "HTTP/1.0 404\r\n\r\n";
	    close($s);
	    next;
	}
	
	my $buf;
	my $sz = -s $path;
	print $s "HTTP/1.0 200\r\n";
	my $type = 'text/plain';
	if ($path =~ /\.([^.]+)$/)
	{
	    $type = $type_map{$1};
	    $type = 'text/plain' if $type eq '';
	}
	print $s "Content-type: $type\r\n";
	print $s "Content-length: $sz\r\n";
	print $s "\r\n";
	
	while (read(TMP, $buf, 4096))
	{
	    print $s $buf;
	}
	close(TMP);
    }
    else
    {
	# can save $req, $content here:
	# open(F, ">request"); print F $req, $content; close(F);
	
	my $stdin_pipe = IO::Pipe->new();
	my $stdout_pipe = IO::Pipe->new();
	
	my $child_pid = fork;
	if ($child_pid == 0)
	{
	    $stdin_pipe->reader();
	    open(STDIN, "<&", $stdin_pipe);
	    $stdout_pipe->writer();
	    open(STDOUT, ">&", $stdout_pipe);
	    exec $sgv;
	}
	$stdin_pipe->writer();
	$stdout_pipe->reader();
	
	print $stdin_pipe $content;
	close($stdin_pipe);
	my $buf;
	print $s "HTTP/1.0 200\r\n";
	while (read($stdout_pipe, $buf, 4096))
	{
	    print $s $buf;
	    # print STDERR $buf;
	}
	close($stdout_pipe);
	print STDERR "waiting for $child_pid\n";
	my $rc = waitpid $child_pid, 0;
	print "child status $rc $?\n";
    }	
    close($s);
}
