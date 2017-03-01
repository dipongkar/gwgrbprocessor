#!/usr/bin/perl

#=== Specify LIGO run =nd its data==#
$LIGORUN = 'O2';
#$LIGORUN_START_TIME = 'Nov 30 2016 16:00:00 UTC';
$LIGORUN_START_TIME = 'Jan 03 2017 20:00:00 UTC';
$LIGORUN_END_TIME = 'July 31 2017 16:00:00 UTC';
#$LIGORUN_START_TIME = 'Sep 18 2015 15:00:00 UTC';
#$LIGORUN_END_TIME = 'Jan 29 2016 08:00:00 UTC';
#=== Specify segment parameters ===#
#@ALLIFOS = ('H1','L1','V1');
@ALLIFOS = ('H1','L1');
#@SEGMENTTYPE = ('DMT-SCIENCE:1','DMT-SCIENCE:1','ITF_SCIENCEMODE');
@SEGMENTTYPE = ('DMT-ANALYSIS_READY:1','DMT-ANALYSIS_READY:1');
#=== Options for data find ===#
#$DATASERVER   = "ldr.ligo.caltech.edu";
$DATASERVER   = "ldrslave.ldas.cit";
#$SEGSERVER    = "https://segdb-er.ligo.caltech.edu";
#$SEGSERVER    = "https://dqsegdb5.phy.syr.edu";
$SEGSERVER    = "https://segments.ligo.org";
#$FRAMETYPE    = "ER_C00_L1";
$FRAMETYPE    = "llhoft";
#$FRAMETYPEV = "V1Online";
$PUBSERVER   = "https://ldas-jobs.ligo.caltech.edu";
#=== Specify earliest GRB date to analyze ===#
$MINGRBDATE = 1164524490; 
#=== Specify maximum Fermi error (in degrees) to analyze ===#
$FERMIERRORMAX = 180;
#=== Annotate GraceDB or not =======
$ANNOTATEFLAG = 'YES';
$FAP_TH = 0.01;

$FRAMELEN    = 4;
#$FRAMELEN    = 256;
#$FRAMELENV = 4000;

#=== Set sleep time in seconds between processing periods ===#
$TIMEDELAY      = 5*60;     

#=== Set sleep time in seconds between monitoring periods ===#
$MONDELAY = 5*60; 

#=== Set max delay of data transfer and segment durations for X-pipeline ===#
$DATADELAY_X     = 20*60+30*60; # ~30 min delay in data transfer for ER6?
$SEGDURATION_X   = 3*3600;
$SEGDURATIONLEFT_X = 9600;
$X_VERSION = '5252M';
$X_POST_VERSION = '5252M';

#=== Set max delay of data transfer and segment durations for CBC-pipeline ===#
$DATADELAY_CBC    = 20*60+30*60; # ~30 min delay in data transfer for ER6?
$SEGDURATION_CBC  = 2*5096;
$SEGDURATIONLEFT_CBC  = 8992;

1;
