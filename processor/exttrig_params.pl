#!/usr/bin/perl

#=== Specify LIGO run =nd its data==#
$LIGORUN = 'preER7';
$LIGORUN_START_TIME = 'Feb 15 2015 00:00:00 UTC';
$LIGORUN_END_TIME = 'June 30 2015 00:00:00 UTC';
#=== Specify segment parameters ===#
#@ALLIFOS = ('H1','L1','V1');
@ALLIFOS = ('H1','L1');
#@SEGMENTTYPE = ('DMT-SCIENCE:1','DMT-SCIENCE:1','ITF_SCIENCEMODE');
@SEGMENTTYPE = ('DMT-ANALYSIS_READY:1','DMT-ANALYSIS_READY:1');
#=== Options for data find ===#
$DATASERVER   = "ldr.ligo.caltech.edu";
#$SEGSERVER    = "https://segdb-er.ligo.caltech.edu";
$SEGSERVER    = "https://dqsegdb5.phy.syr.edu";
#$FRAMETYPE    = "ER_C00_L1";
$FRAMETYPE    = "ER_C00_AGG";
#$FRAMETYPEV = "V1Online";
$PUBSERVER   = "https://ldas-jobs.ligo.caltech.edu";
#=== Specify earliest GRB date to analyze ===#
$MINGRBDATE = 1100044816; 
#=== Specify maximum Fermi error (in degrees) to analyze ===#
$FERMIERRORMAX = 180;

#$FRAMELEN    = 4;
$FRAMELEN    = 256;
#$FRAMELENV = 4000;

#=== Set sleep time in seconds between processing periods ===#
$TIMEDELAY      = 5*60;     

#=== Set sleep time in seconds between monitoring periods ===#
$MONDELAY = 5*60; 

#=== Set max delay of data transfer and segment durations for X-pipeline ===#
$DATADELAY_X     = 20*60+1*60*60; # ~1 hours delay in data transfer for ER6?
$SEGDURATION_X   = 3*3600;
$SEGDURATIONLEFT = 9600;

#=== Set max delay of data transfer and segment durations for CBC-pipeline ===#
$DATADELAY_CBC    = 1098+1*60*60; # ~1 hours delay in data transfer for ER6?
$OFFSET           = 1098;
$SEGDURATION_CBC  = 1098;


1;
