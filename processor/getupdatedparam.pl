#!/usr/bin/perl -w

require '/home/grb.exttrig/Online/O2/processor/exttrig_params.pl';

# === Capture arg ===#
$grbName = $ARGV[0];
$pipeline = $ARGV[1];

#=== Get user name ===#
$USERNAME = `whoami`;
chomp($USERNAME);

#=== Specify local working directories ===#
$HOMEDIR = sprintf "/home/%s", $USERNAME;
$GRBDIR  = sprintf "%s/Online/%s/processor/grbs/updated_param", $HOMEDIR, $LIGORUN;

#=== Prepare query command ===#
$queryCommand = sprintf "gracedb search %s --columns=gpstime,extra_attributes.GRB.ra,extra_attributes.GRB.dec,extra_attributes.GRB.error_radius,extra_attributes.GRB.trigger_duration > %s/%s_updatedparam_%s.txt\n",$grbName, $GRBDIR, $grbName, $pipeline;
$queryResult = system $queryCommand;
