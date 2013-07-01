#!/opt/local/bin/perl

#############################################
# -=[ Virtual Patching Converter Script ]=- #
#   Converts to previous modsec versions    #
#                                           #
#             modsec2modsec.pl              #
#               Version: 1.0                #
#                                           #
#            Copyright 2013                 #
#  Mathieu Parent <math.parent@gmail.com>   #
#############################################

use strict;
use warnings;
use Getopt::Std;
use File::Find ();
use File::Copy;

# Parse options
my %opts;
getopts("t:f:nvd",\%opts);
my $target_version = $opts{'t'};
my $filename = $opts{'f'};
my $no_backup = $opts{'n'};
my $verbose = $opts{'v'};
my $debug = $opts{'d'};

# Check options
unless ($target_version && $filename) {
    print "Flag:\n\n".
      "\t -t:\t target version\n".
      "\t -f:\t file or directory to convert\n".
      "\t -n:\t no backup file\n".
      "\t -v:\t be verbose\n".
      "\t -d:\t debug\n".
      "Usage:\n\n".
      "\t./modsec2modsec.pl -t 2.6 -f .\n\n";
    exit 1;
}
unless ($target_version eq '2.6') {
  print "Unknown target version $target_version. Use one of: 2.6.\n";
  exit 1;
}
my @target_version  = split( /\./, $target_version );

# Suffixes
my $bck = '.old'; # Backup suffix
my $tmp = '.tmp'; # Tempfile suffix

# Traverse directory
File::Find::find({wanted => \&process, no_chdir => 1}, $filename);

exit 0;

sub target_version_below {
  # Caveats: Only versions X.Y are supported
  my @ver  = split( /\./, shift );
  return ( $target_version[0] < $ver[0]
          || $target_version[1] < $ver[1] );
}

sub process {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);

    (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) &&
    -f _ &&
    /^.*\.conf\z/s
    && process_file($File::Find::name);
}

sub process_file {
  my $filename = shift;
  print "Processing $filename\n" if $verbose;
  # Clean up any remaining tempfile
  if (-f "$filename$tmp") {
    print "Deleting $filename$tmp\n" if $debug;
    unlink "$filename$tmp" or die "Unable to delete $filename$tmp: $!";
  }
  # Open both input and output
  open(my $input, '<', $filename) or die "Unable to open $filename: $!";
  open(my $output, '>', "$filename$tmp") or die "Unable to open $filename$tmp: $!";
  # Read input line by line
  while (<$input>) {
    if (target_version_below('2.7')) {
      s/ver:'[^']+',//;
      s/maturity:'[^']+',//;
      s/accuracy:'[^']+',//;
    }
    print $output $_;
  }
  close($input);
  close($output);
  if (!$no_backup && -f "$filename$bck") {
    print "Deleting $filename$bck\n" if $debug;
    unlink "$filename$bck" or die "Unable to delete $filename$bck: $!";
  }
  if (!$no_backup) {
    print "Moving $filename to $filename$bck\n" if $debug;
    move($filename, "$filename$bck") or die "Unable to move $filename to $filename$bck: $!";
  }
  print "Moving $filename$tmp to $filename\n" if $debug;
  move("$filename$tmp", $filename) or die "Unable to open $filename$tmp to $filename: $!";
}
