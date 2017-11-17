use strict;
use warnings;
use LWP::UserAgent;

my $base = 'http://www.uniprot.org';
my $tool = 'blast';

my $from = $ARGV[0];
my $to = $ARGV[1];
my $GI = $ARGV[2];

my $params = {
  query => "TTCCPSIVARSNFNVCRLPGTPEAICATYTGCIIIPGATCPGDYAN",
  dataset => "uniprotkb",
  threshold => "10",
  filter => "false",
  gapped => "true",
  numal => "250"
};

my $contact = 'araujopa@gmail.com'; # Please set your email address here to help us debug in case of problems.
my $agent = LWP::UserAgent->new(agent => "libwww-perl $contact");
push @{$agent->requests_redirectable}, 'POST';

my $response = $agent->post("$base/$tool/", $params);

while (my $wait = $response->header('Retry-After')) {
  print STDERR "Waiting ($wait)...\n";
  sleep $wait;
  $response = $agent->get($response->base);
}

$response->is_success ?
  print $response->content :
  die 'Failed, got ' . $response->status_line .
    ' for ' . $response->request->uri . "\n";