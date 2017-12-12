#!/usr/bin/perl -w
use strict;

use SeedEnv;
use Tracer;
use Stats;
use ServerThing;

=head1 svr_submit_correspondences

    svr_submit_correspondences [--url=<url>] [--cleanOnly] [--fixup] [--passive] <directory1> <directory2> ...

Locate all the correspondence files in the specified directories and submits
then to the Sapling Server. It is not a real SAS script and is intended for
internal use only.

This script assumes the directory is divided into subdirectories by genome ID.
Each correspondence file has the name of the target genome ID and is in a directory
with the name of the source genome ID. The script can also be used to clean an
existing directory of files that have already been submitted.

=head2 Command-Line Options

=over 4

=item cleanOnly

If specified, then no correspondences will be submitted. Instead, files from the
directory that are redundant will be deleted.

=item passive

If specified, then only files for correspondences that don't already exist will
be submitted.

=item fixup

If specified, then only correspondence files that need to be flipped will be
submitted. This is a special fix to repair an error in a previous run.

=item parseFiles

If specified, then the correspondence files will be checked for errors but
not submitted.

=item url

The URL for the sapling server, if it is to be different from the default.

=back

=cut

my ($options, @directories) = StandardSetup([qw(SAP ServerThing Corr)],
                                          { url => ["", "target server URL"],
                                            cleanOnly => ["", "if specified, the directory will be cleaned and no files will be submitted"],
                                            fixup => ["", "if specified, only files that may have caused the file-flipping but will be submitted"],
                                            passive => ["", "if specified, correspondences already in the system will not be resubmitted"],
                                            parseFiles => ["", "if specified, the files will be checked for errors, but not submitted"] },
                                          "<directory>", @ARGV);
# Get the input directory.
if (! @directories) {
    Confess("No directory specified.");
} else {
    # Get a sapling server object.
    my $sapObject = SAPserver->new(url => $options->{url});
    Trace("Using server at $sapObject->{server_url}.") if T(2);
    # Create a statistics object.
    my $stats = Stats->new();
    # Loop through the directory list.
    for my $directory (@directories) {
        Trace("Processing master directory $directory.") if T(2);
        # Insure this directory exists.
        if (! -d $directory) {
            Trace("Directory $directory not found.") if T(0);
        } else {
            # Get all the subdirectories.
            my @dirs = grep { $_ =~ /^\d+\.\d+$/ } OpenDir($directory, 0);
            Trace(scalar(@dirs) . " genome directories found.") if T(2);
            # Check for passive mode.
            my $passive = ($options->{passive} ? 1 : 0);
            # Loop through the directories.
            for my $genome1 (@dirs) {
                Trace("Processing directory $genome1.") if T(2);
                # Get the genomes in this directory.
                my @files = grep { $_ =~ /^\d+\.\d+$/ } OpenDir("$directory/$genome1");
                for my $genome2 (sort @files) {
                    # Compute the full file name.
                    my $fileName = "$directory/$genome1/$genome2";
                    # Does this correspondence exist?
                    my $corrExists = defined $sapObject->gene_correspondence_map(-genome1 => $genome1,
                                                                                 -genome2 => $genome2,
                                                                                 -passive => 1);
                    # Are we cleaning or parsing?
                    if ($options->{parseFiles}) {
                        # Parsing. Read the file and validate the rows.
                        Trace("Checking $fileName.") if T(2);
                        my $list = ServerThing::ReadGeneCorrespondenceFile($fileName);
                        if (! defined $list) {
                            Trace("Errors found in $fileName.") if T(1);
                        } else {
                            Trace("$fileName validated.") if T(2);
                        }
                    } elsif ($options->{cleanOnly}) {
                        # Cleaning. Check to see if we should delete the file.
                        if ($corrExists) {
                            my $ok = unlink $fileName;
                            if ($ok) {
                                Trace("File $fileName deleted.") if T(2);
                                $stats->Add(deleted => 1);
                            } else {
                                Trace("Failed to delete $fileName.") if T(2);
                                $stats->Add(deleteFailed => 1);
                            }
                        } else {
                            $stats->Add(notFound => 1);
                        }
                    } else {
                        # Check for a fixup run. In that case, we only submit if the
                        # genome IDs are out of order. Similarly, in passive mode we only submit
                        # if the correspondence doesn't exist already.
                        if ($options->{fixup} && ! ServerThing::MustFlipGenomeIDs($genome1, $genome2)) {
                            $stats->Add(noFixNeeded => 1);
                        } elsif ($passive && $corrExists) {
                            $stats->Add(skippedPassive => 1);
                        } else {
                            # Here we want to store the correspondence. Read the file.
                            my $ih = Open(undef, "<$fileName");
                            my @correspondences;
                            while (! eof $ih) {
                                push @correspondences, [ Tracer::GetLine($ih) ];
                            }
                            # Submit it to the server.
                            my $ok = $sapObject->submit_gene_correspondence(-genome1 => $genome1,
                                                                            -genome2 => $genome2,
                                                                            -correspondences => \@correspondences,
                                                                            -passive => $passive);
                            if ($ok) {
                                $stats->Add(submitted => 1);
                                Trace("$fileName submitted to server.") if T(2);
                            } else {
                                $stats->Add(failed => 1);
                                Trace("Failure submitting $fileName to server.") if T(2);
                            }
                        }
                    }
                }
            }
        }
    }
    Trace("Run complete.\n" . $stats->Show()) if T(2);
}

