sub findIFONetwork {

  my($ligoRun)     = $_[0];
  my($ifos)        = $_[1];
  my($grbGPS)      = $_[2];
  my($gpsStart)    = $_[3];
  my($gpsEnd)      = $_[4];
  my($minDuration) = $_[5];
  my($segmentType) = $_[6];
  my($dataServer)  = $_[7];

  my(@netIfos,$ifo,$segFindCommand,@segResults,$segResult,$searchDuration,
     $invalidSegmentFlag,$segStart,$segEnd,$runType,$runNumber,
     $startPad,$endPad,$iifo);

  @netIfos = ();
  $searchDuration = $gpsEnd - $gpsStart;

  $runType   = substr($ligoRun,0,1);
  $runNumber = substr($ligoRun,1,1);

  $startPad = $grbGPS - $gpsStart;
  $endPad   = $gpsEnd - $grbGPS;

  $iifo = 0;
  foreach $ifo (@$ifos) {
      $segFindCommand = sprintf "ligolw_segment_query_dqsegdb --segment %s --include-segments %s:%s", $dataServer, $ifo, uc(@$segmentType[$iifo]);
      $segFindCommand = sprintf "%s --gps-start-time %d --gps-end-time %d --query-segments", $segFindCommand, $gpsStart, $gpsEnd;


    printf "$segFindCommand\n";

    @segResults = ();
    @segResults = `$segFindCommand`;
    chomp(@segResults);

    $invalidSegmentFlag = 0;
    #=== If science run is post-S5 use new segment commands ===#
      my($segStartRef,$segEndRef,$totalSegDuration) = parseSegmentsXml(\@segResults);
      my(@segGpsStart) = @$segStartRef;
      my(@segGpsEnd)   = @$segEndRef;
      if ($#segGpsStart + 1 == 1 && $totalSegDuration >= $minDuration) {
        push(@netIfos,$ifo);
      }
    $iifo++;
  }
  return @netIfos;
}

sub querySegments {

  #use Switch;
  #use strict;
  use warnings;
  use feature qw(switch say);

  my($ligoRun)       = $_[0];
  my($ifos)          = $_[1];
  my($grbGPS)        = $_[2];
  my($gpsStart)      = $_[3];
  my($gpsEnd)        = $_[4];
  my($minDuration)   = $_[5];
  my($segmentType)   = $_[6];
  my($dataServer)    = $_[7];
  my($writeSegsFlag) = $_[8];
  my($jobDir)        = $_[9];

  my(@netIfos,$ifo,$segFindCommand,@segResults,$segResult,$searchDuration,
     $invalidSegmentFlag,$segStart,$segEnd,$runType,$runNumber,
     $startPad,$endPad,$iifo);

  @netIfos = ();
  $searchDuration = $gpsEnd - $gpsStart;

  $runType   = substr($ligoRun,0,1);
  $runNumber = substr($ligoRun,1,1);

  $startPad = $grbGPS - $gpsStart;
  $endPad   = $gpsEnd - $grbGPS;
  
  $iifo = 0;
  my(@segmentFlag) = ();
  foreach $ifo (@$ifos) {
    $inet = -1;
    #switch ($ifo) {
    given ($ifo) {
      #case 'H1'
      when ('H1')
      {
        $inet = 0;
      }
      #case 'L1'
      when ('L1')
      {
        $inet = 1;
      }
    }

    $segmentFlag[$iifo] = 0;
      $segFindCommand = sprintf "ligolw_segment_query_dqsegdb --segment %s --include-segments %s:%s", $dataServer, $ifo, uc(@$segmentType[$inet]);
      $segFindCommand = sprintf "%s --gps-start-time %d --gps-end-time %d --query-segments", $segFindCommand, $gpsStart, $gpsEnd;

    printf "$segFindCommand\n";

    @segResults = ();
    @segResults = `$segFindCommand`;
    chomp(@segResults);

    $invalidSegmentFlag = 0;
    #=== If science run is post-S5 use new segment commands ===#
      my($segStartRef,$segEndRef,$totalSegDuration) = parseSegmentsXml(\@segResults);
      my(@segGpsStart) = @$segStartRef;
      my(@segGpsEnd)   = @$segEndRef;
      if ($totalSegDuration >= $minDuration) {
        $segmentFlag[$iifo] = 1;
        if ($writeSegsFlag == 1) {
          &writeSegments($jobDir,$ifo,\@segGpsStart,\@segGpsEnd);
        }
      }

    $iifo++;
  }
  return @segmentFlag;
}

sub parseSegmentsXml {

  my($xmlTable) = $_[0];

  my($streamStart) = 'Stream Delimiter="," Type="Local" Name="segment:table"';
  my($streamEnd)   = '/Stream';
  my(@segStart)    = ();
  my(@segEnd)      = ();
  my($totalDuration) = 0;

  my($xmlLine,$dstring1,$dstring2,$dstring3);
  my($iseg) = 0;
  my($streamFlag) = 0;
  foreach $xmlLine (@$xmlTable) {
    if ($streamFlag == 0) {
      if ($xmlLine =~ /$streamStart/) {
        $streamFlag = 1;
        next;
      }
    } else {
      if ($xmlLine =~ /$streamEnd/) {
        last;
      } else {
        ($dstring1,$dstring2,$dstring3,$segStart[$iseg],$dstring4,$segEnd[$iseg]) = split(/,/,$xmlLine);
        printf "iseg %3d %d %d %d\n", $iseg, $segStart[$iseg], $segEnd[$iseg], $segEnd[$iseg] - $segStart[$iseg];
        $totalDuration += $segEnd[$iseg] - $segStart[$iseg];
        $iseg++;
      }
    }
  }
  printf "\n%d\n", $totalDuration;
  return (\@segStart,\@segEnd,$totalDuration);
}

sub writeSegments {

  my($jobDir)   = $_[0];
  my($ifo)      = $_[1];
  my($segStart) = $_[2];
  my($segEnd)   = $_[3];

  my($segFile) = sprintf "%s/segments_science_%s.txt", $jobDir, $ifo;
  open SEGFILE, ">>$segFile"
    or die "Error opening file $segFile: $!";

  my($iseg) = 0;
  my($segGps);
  foreach $segGps (@$segStart) {
    printf SEGFILE "%4d %10d %10d %6d\n", $iseg, @$segStart[$iseg], @$segEnd[$iseg], @$segEnd[$iseg]-@$segStart[$iseg];
    $iseg++;
  }
}

sub configIFONetwork {
 
  #use Switch;
  #use strict;
  use warnings;
  use feature qw(switch say);

  my($netIfosRef)      = $_[0];
  my($jobDir)          = $_[1];
  my($lagFileToken)    = $_[2];
  my($likelihoodToken) = $_[3];

  my($ifoString,$ifo,$lagFile,$likelihoodType,$nifos,$sedCommand);

  my(@netIfos) = @$netIfosRef;

  $ifoString = '';
  foreach $ifo (@netIfos) {
    $ifoString = "$ifoString"."$ifo";
  }

  return $ifoString;

}

sub updateWebStatus {

  #use Switch;
  #use strict;
  use warnings;
  use feature qw(switch say);

  my($statusTableRef) = $_[0];
  my($htmlFile)       = $_[1];
  my($lineOffset)     = $_[2];
  my($resultsLink)    = $_[3];
  my($openboxLink)    = $_[4];

# my(%searchStatusTable) = %$statusTableRef;
  my($searchStatusTable) = $statusTableRef;

  my($tableKey,$tempFile,$tableInsertTag,$insertData,$sedCommand,$lineNumber,$htmlString,$cpCommand);
  my($grbName,$grbGPS,$grbDate,$grbTime,$grbRA,$grbDec,$grbError,$ifoString,$grbSat,$grbTrigDur,$jobId,$latency,$jobRunTime,$jobStatus,$rescueCtr,$jobStatusColor);

  $tempFile = sprintf "%s.temp", $htmlFile;

  $tableInsertTag = 'Insert new GRBs here';

  $rescueCtr = -1;

  foreach $tableKey (keys %$searchStatusTable) {
    #printf "%s %s\n", $tableKey, $searchStatusTable->{$tableKey};
    #switch ($tableKey) {
    #  case 'GRB_NAME'      { $grbName    = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_GPS'       { $grbGPS     = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_DATE'      { $grbDate    = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_TIME'      { $grbTime    = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_RA'        { $grbRA      = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_DEC'       { $grbDec     = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_ERR'       { $grbError   = $searchStatusTable->{$tableKey}; }
    #  case 'IFO_STRING'    { $ifoString  = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_SAT'       { $grbSat     = $searchStatusTable->{$tableKey}; }
    #  case 'TRIG_DUR'      { $grbTrigDur = $searchStatusTable->{$tableKey}; }
    #  case 'JOB_CLUSTER'   { $jobId      = $searchStatusTable->{$tableKey}; }
    #  case 'LATENCY'       { $latency    = $searchStatusTable->{$tableKey}; }
    #  case 'RUN_TIME'      { $jobRunTime = $searchStatusTable->{$tableKey}; }
    #  case 'JOB_STATUS'    { $jobStatus  = $searchStatusTable->{$tableKey}; }
    #  case 'RESCUE_CTR'    { $rescueCtr  = $searchStatusTable->{$tableKey}; }
    given ($tableKey) {
      when ('GRB_NAME')      { $grbName    = $searchStatusTable->{$tableKey}; }
      when ('GRB_GPS')       { $grbGPS     = $searchStatusTable->{$tableKey}; }
      when ('GRB_DATE')      { $grbDate    = $searchStatusTable->{$tableKey}; }
      when ('GRB_TIME')      { $grbTime    = $searchStatusTable->{$tableKey}; }
      when ('GRB_RA')        { $grbRA      = $searchStatusTable->{$tableKey}; }
      when ('GRB_DEC')       { $grbDec     = $searchStatusTable->{$tableKey}; }
      when ('GRB_ERR')       { $grbError   = $searchStatusTable->{$tableKey}; }
      when ('IFO_STRING')    { $ifoString  = $searchStatusTable->{$tableKey}; }
      when ('GRB_SAT')       { $grbSat     = $searchStatusTable->{$tableKey}; }
      when ('TRIG_DUR')      { $grbTrigDur = $searchStatusTable->{$tableKey}; }
      when ('JOB_CLUSTER')   { $jobId      = $searchStatusTable->{$tableKey}; }
      when ('LATENCY')       { $latency    = $searchStatusTable->{$tableKey}; }
      when ('RUN_TIME')      { $jobRunTime = $searchStatusTable->{$tableKey}; }
      when ('JOB_STATUS')    { $jobStatus  = $searchStatusTable->{$tableKey}; }
      when ('RESCUE_CTR')    { $rescueCtr  = $searchStatusTable->{$tableKey}; }
    }
  }

  #=== Specify job status color ===#
  #switch ($jobStatus) {
  #  case 'PROCESSED' { $jobStatusColor = "jobstatus"; }
  #  case 'RUNNING'   { $jobStatusColor = "jobrun"; }
  #  case 'SUBMITTED' { $jobStatusColor = "jobsubmit"; }
  #  case 'DATACUT'   { $jobStatusColor = "jobcut"; }
  #  case 'IDLE'      { $jobStatusColor = "jobidle"; }
  #  case 'HELD'      { $jobStatusColor = "jobheld"; }
  #  else             { $jobStatusColor = "jobfail"; }
  given ($jobStatus) {
    when ('PROCESSED') { $jobStatusColor = "jobstatus"; }
    when ('RUNNING')   { $jobStatusColor = "jobrun"; }
    when ('SUBMITTED') { $jobStatusColor = "jobsubmit"; }
    when ('DATACUT')   { $jobStatusColor = "jobcut"; }
    when ('IDLE')      { $jobStatusColor = "jobidle"; }
    when ('HELD')      { $jobStatusColor = "jobheld"; }
    default            { $jobStatusColor = "jobfail"; }
  }

  #=== Check if this GRB has an entry in the html file ===#
  $sedCommand = '';
  $sedCommand = sprintf "sed -n '/\"grbname\" rowspan=\"2\"><a href=\"https:\\/\\/gracedb.ligo.org\\/events\\/%s\">%s</=' %s", $grbName, $grbName, $htmlFile;
  $lineNumber = -1;
  $lineNumber = `$sedCommand`;
  chomp($lineNumber);

  if ($lineNumber =~ /^[1-9]/) {

    #=== For Coh and ifo string col.  ===#
    $lineNumberpre = $lineNumber + 2;
    $htmlStringpre = sprintf
       " <td class=\"pipeline\">%s<\\/td> <td class=\"network\">%s<\\/td>",
               'X-pipeline', $ifoString;
    $sedCommandpre = sprintf "sed '%ds/.*/%s/' %s > %s",
             $lineNumberpre, $htmlStringpre, $htmlFile, $tempFile;
printf "$sedCommandpre\n";
    system $sedCommandpre;

    $cpCommandpre = sprintf "cp %s %s", $tempFile, $htmlFile;
    system $cpCommandpre;

    #=== If the GRB already has an entry,  ===#
    #=== replace the entry with new status ===#
    $lineNumber = $lineNumber + $lineOffset;
    if ($resultsLink eq '' && $openboxLink eq '') {
      if ($rescueCtr == -1) {
        $htmlString = sprintf
        $htmlString = sprintf 
           "  <td class=\"jobid\">%s<\\/td> <td class=\"jobruntime\">%s<\\/td> <td class=\"%s\">%s<\\/td>",
                      $jobId, $jobRunTime, $jobStatusColor, $jobStatus;
      } else {
        $htmlString = sprintf 
           "  <td class=\"jobid\">%s<\\/td> <td class=\"latency\">%s<\\/td>  <td class=\"jobruntime\">%s<\\/td> <td class=\"%s\">%s<\\/td> <td class=\"rescuectr\">%s<\\/td>",
                      $jobId, $latency, $jobRunTime, $jobStatusColor, $jobStatus, $rescueCtr;
      }
    } else {
      if ($openboxLink eq '') {
        $htmlString = sprintf 
           "  <td class=\"jobid\">%s<\\/td> <td class=\"jobruntime\">%s<\\/td> <td class=\"%s\"><a href=\"%s\">%s<\\/a><\\/td>",
                      $jobId, $jobRunTime, $jobStatusColor, $resultsLink, $jobStatus;
      } else {
        $htmlString = sprintf 
           "  <td class=\"openbox\"><a href=\"%s\">%s<\\/a><\\/td>",
                      $openboxLink, 'OPEN';
      }
    }
    $sedCommand = sprintf "sed '%ds/.*/%s/' %s > %s",
             $lineNumber, $htmlString, $htmlFile, $tempFile;
printf "$sedCommand\n";
    system $sedCommand;

    $cpCommand = sprintf "cp %s %s", $tempFile, $htmlFile;
    system $cpCommand;
  } else {
    #=== Append new GRB ===#
    #=== Format table entry to insert in HTML table ===#

    $insertData = sprintf "\n<tr>\\\n";

    $insertData = sprintf "%s  <td class=\"grbname\" rowspan=\"2\"><a href=\"https://gracedb.ligo.org/events/%s\">%s</a></td> <td class=\"grbsat\" rowspan=\"2\">%s</td> <td class=\"grbdate\" rowspan=\"2\">%s, %s</td> <td class=\"grbgps\" rowspan=\"2\">%s</td> <td class=\"grbdur\" rowspan=\"2\">%s</td>\\\n", 
                           $insertData, $grbName, $grbName, $grbSat, $grbDate, $grbTime, $grbGPS, $grbTrigDur;
    $insertData = sprintf "%s  <td class=\"grbra\" rowspan=\"2\">%s</td> <td class=\"grbdec\" rowspan=\"2\">%s</td> <td class=\"grberr\" rowspan=\"2\">%s</td>\\\n", 
                           $insertData, $grbRA, $grbDec, $grbError;
    $insertData = sprintf "%s <td class=\"pipeline\">%s</td> <td class=\"network\">%s</td>\\\n",
                           $insertData, 'X-pipeline', $ifoString;
    $insertData = sprintf "%s  <td class=\"jobid\">%s</td> <td class=\"latency\">%s</td> <td class=\"jobruntime\">%s</td> <td class=\"%s\">%s</td> <td class=\"rescuectr\">%s</td>\\\n", 
                           $insertData, $jobId, $latency, $jobRunTime, $jobStatusColor, $jobStatus, $rescueCtr;
    $insertData = sprintf "%s  <td class=\"jobid\">%s</td> <td class=\"jobruntime\">%s</td> <td class=\"jobstatus\">%s</td>\\\n", 
                           $insertData, '--', '--', '--';
    $insertData = sprintf "%s  <td class=\"openbox\">%s</td>\\\n", $insertData, '--';

    $insertData = sprintf "%s</tr>\\\n", $insertData;

    $insertData = sprintf "%s<tr>\\\n", $insertData;

    $insertData = sprintf "%s  <td class=\"pipeline\">%s</td> <td class=\"network\">%s</td>\\\n",    
                           $insertData, 'PyGRB+cohPTF', '--';
    $insertData = sprintf "%s  <td class=\"jobid\">%s</td> <td class=\"latency\">%s</td> <td class=\"jobruntime\">%s</td> <td class=\"jobstatus\">%s</td> <td class=\"rescuectr\">%s</td>\\\n",
                           $insertData, '--', '--', '--', '--', '--';
    $insertData = sprintf "%s  <td class=\"jobid\">%s</td> <td class=\"jobruntime\">%s</td> <td class=\"jobstatus\">%s</td>\\\n",
                           $insertData, '--', '--', '--';
    $insertData = sprintf "%s  <td class=\"openbox\">%s</td>\\\n", $insertData, '--';
   
    $insertData = sprintf "%s</tr>\n", $insertData;

    #=== Perform sed command ===#
    $sedCommand = sprintf "sed '/%s/a\\%s' %s > %s", $tableInsertTag, $insertData, $htmlFile, $tempFile;
printf "$sedCommand\n";
    system $sedCommand;

    $cpCommand = sprintf "cp %s %s", $tempFile, $htmlFile;
    system $cpCommand;

  }
}


sub updateWebStatusPTF {

  #use Switch;
  #use strict;
  use warnings;
  use feature qw(switch say);

  my($statusTableRef) = $_[0];
  my($htmlFile)       = $_[1];
  my($lineOffset)     = $_[2];
  my($resultsLink)    = $_[3];
  my($openboxLink)    = $_[4];

# my(%searchStatusTable) = %$statusTableRef;
  my($searchStatusTable) = $statusTableRef;

  my($tableKey,$tempFile,$tableInsertTag,$insertData,$sedCommand,$lineNumber,$htmlString,$cpCommand);
  my($grbName,$grbGPS,$grbDate,$grbTime,$grbRA,$grbDec,$grbError,$ifoString,$grbSat,$grbTrigDur,$jobId,$latency,$jobRunTime,$jobStatus,$rescueCtr,$jobStatusColor);

  $tempFile = sprintf "%s.temp", $htmlFile;

  $tableInsertTag = 'Insert new GRBs here';

  $rescueCtr = -1;

  foreach $tableKey (keys %$searchStatusTable) {
    #printf "%s %s\n", $tableKey, $searchStatusTable->{$tableKey};
    #switch ($tableKey) {
    #  case 'GRB_NAME'      { $grbName    = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_GPS'       { $grbGPS     = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_DATE'      { $grbDate    = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_TIME'      { $grbTime    = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_RA'        { $grbRA      = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_DEC'       { $grbDec     = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_ERR'       { $grbError   = $searchStatusTable->{$tableKey}; }
    #  case 'IFO_STRING'    { $ifoString  = $searchStatusTable->{$tableKey}; }
    #  case 'GRB_SAT'       { $grbSat     = $searchStatusTable->{$tableKey}; }
    #  case 'TRIG_DUR'      { $grbTrigDur = $searchStatusTable->{$tableKey}; }
    #  case 'JOB_CLUSTER'   { $jobId      = $searchStatusTable->{$tableKey}; }
    #  case 'LATENCY'       { $latency    = $searchStatusTable->{$tableKey}; }
    #  case 'RUN_TIME'      { $jobRunTime = $searchStatusTable->{$tableKey}; }
    #  case 'JOB_STATUS'    { $jobStatus  = $searchStatusTable->{$tableKey}; }
    #  case 'RESCUE_CTR'    { $rescueCtr  = $searchStatusTable->{$tableKey}; }
    given ($tableKey) {
      when ('GRB_NAME')      { $grbName    = $searchStatusTable->{$tableKey}; }
      when ('GRB_GPS')       { $grbGPS     = $searchStatusTable->{$tableKey}; }
      when ('GRB_DATE')      { $grbDate    = $searchStatusTable->{$tableKey}; }
      when ('GRB_TIME')      { $grbTime    = $searchStatusTable->{$tableKey}; }
      when ('GRB_RA')        { $grbRA      = $searchStatusTable->{$tableKey}; }
      when ('GRB_DEC')       { $grbDec     = $searchStatusTable->{$tableKey}; }
      when ('GRB_ERR')       { $grbError   = $searchStatusTable->{$tableKey}; }
      when ('IFO_STRING')    { $ifoString  = $searchStatusTable->{$tableKey}; }
      when ('GRB_SAT')       { $grbSat     = $searchStatusTable->{$tableKey}; }
      when ('TRIG_DUR')      { $grbTrigDur = $searchStatusTable->{$tableKey}; }
      when ('JOB_CLUSTER')   { $jobId      = $searchStatusTable->{$tableKey}; }
      when ('LATENCY')       { $latency    = $searchStatusTable->{$tableKey}; }
      when ('RUN_TIME')      { $jobRunTime = $searchStatusTable->{$tableKey}; }
      when ('JOB_STATUS')    { $jobStatus  = $searchStatusTable->{$tableKey}; }
      when ('RESCUE_CTR')    { $rescueCtr  = $searchStatusTable->{$tableKey}; }
    }
  }

  #=== Specify job status color ===#
  #switch ($jobStatus) {
  #  case 'PROCESSED' { $jobStatusColor = "jobstatus"; }
  #  case 'RUNNING'   { $jobStatusColor = "jobrun"; }
  #  case 'SUBMITTED' { $jobStatusColor = "jobsubmit"; }
  #  case 'DATACUT'   { $jobStatusColor = "jobcut"; }
  #  case 'IDLE'      { $jobStatusColor = "jobidle"; }
  #  case 'HELD'      { $jobStatusColor = "jobheld"; }
  #  else             { $jobStatusColor = "jobfail"; }
  given ($jobStatus) {
    when ('PROCESSED') { $jobStatusColor = "jobstatus"; }
    when ('RUNNING')   { $jobStatusColor = "jobrun"; }
    when ('SUBMITTED') { $jobStatusColor = "jobsubmit"; }
    when ('DATACUT')   { $jobStatusColor = "jobcut"; }
    when ('IDLE')      { $jobStatusColor = "jobidle"; }
    when ('HELD')      { $jobStatusColor = "jobheld"; }
    default            { $jobStatusColor = "jobfail"; }
  }

  #=== Check if this GRB has an entry in the html file ===#
  $sedCommand = '';
  $sedCommand = sprintf "sed -n '/\"grbname\" rowspan=\"2\"><a href=\"https:\\/\\/gracedb.ligo.org\\/events\\/%s\">%s</=' %s", $grbName, $grbName, $htmlFile;
  $lineNumber = -1;
  $lineNumber = `$sedCommand`;
  chomp($lineNumber);

  if ($lineNumber =~ /^[1-9]/) {

    #=== For Coh and ifo string col.  ===#
    $lineNumberpre = $lineNumber + 8;
    $htmlStringpre = sprintf
       " <td class=\"pipeline\">%s<\\/td> <td class=\"network\">%s<\\/td>",
               'PyGRB+cohPTF', $ifoString;
    $sedCommandpre = sprintf "sed '%ds/.*/%s/' %s > %s",
             $lineNumberpre, $htmlStringpre, $htmlFile, $tempFile;
printf "$sedCommandpre\n";
    system $sedCommandpre;

    $cpCommandpre = sprintf "cp %s %s", $tempFile, $htmlFile;
    system $cpCommandpre;

    #=== If the GRB already has an entry,  ===#
    #=== replace the entry with new status ===#
    $lineNumber = $lineNumber + $lineOffset;
    if ($resultsLink eq '' && $openboxLink eq '') {
      if ($rescueCtr == -1) {
        $htmlString = sprintf 
           "  <td class=\"jobid\">%s<\\/td> <td class=\"jobruntime\">%s<\\/td> <td class=\"%s\">%s<\\/td>",
                      $jobId, $jobRunTime, $jobStatusColor, $jobStatus;
      } else {
        $htmlString = sprintf 
           "  <td class=\"jobid\">%s<\\/td> <td class=\"latency\">%s<\\/td> <td class=\"jobruntime\">%s<\\/td> <td class=\"%s\">%s<\\/td> <td class=\"rescuectr\">%s<\\/td>",
                     $jobId, $latency, $jobRunTime, $jobStatusColor, $jobStatus, $rescueCtr;
      }
    } else {
      if ($openboxLink eq '') {
        $htmlString = sprintf 
           "  <td class=\"jobid\">%s<\\/td> <td class=\"jobruntime\">%s<\\/td> <td class=\"%s\"><a href=\"%s\">%s<\\/a><\\/td>",
                      $jobId, $jobRunTime, $jobStatusColor, $resultsLink, $jobStatus;
      } else {
        $htmlString = sprintf 
           "  <td class=\"openbox\"><a href=\"%s\">%s<\\/a><\\/td>",
                      $openboxLink, 'OPEN';
      }
    }
    $sedCommand = sprintf "sed '%ds/.*/%s/' %s > %s",
             $lineNumber, $htmlString, $htmlFile, $tempFile;
printf "$sedCommand\n";
    system $sedCommand;

    $cpCommand = sprintf "cp %s %s", $tempFile, $htmlFile;
    system $cpCommand;
  } else {
    #=== Append new GRB ===#
    #=== Format table entry to insert in HTML table ===#

    $insertData = sprintf "\n<tr>\\\n";

    $insertData = sprintf "%s  <td class=\"grbname\" rowspan=\"2\"><a href=\"https://gracedb.ligo.org/events/%s\">%s</a></td> <td class=\"grbsat\" rowspan=\"2\">%s</td> <td class=\"grbdate\" rowspan=\"2\">%s, %s</td> <td class=\"grbgps\" rowspan=\"2\">%s</td> <td class=\"grbdur\" rowspan=\"2\">%s</td>\\\n", 
                           $insertData, $grbName, $grbName, $grbSat, $grbDate, $grbTime, $grbGPS, $grbTrigDur;
    $insertData = sprintf "%s  <td class=\"grbra\" rowspan=\"2\">%s</td> <td class=\"grbdec\" rowspan=\"2\">%s</td> <td class=\"grberr\" rowspan=\"2\">%s</td>\\\n", 
                           $insertData, $grbRA, $grbDec, $grbError;
    $insertData = sprintf "%s  <td class=\"pipeline\">%s</td> <td class=\"network\">%s</td>\\\n",           
                           $insertData, 'X-pipeline', '--';
    $insertData = sprintf "%s  <td class=\"jobid\">%s</td> <td class=\"latency\">%s</td> <td class=\"jobruntime\">%s</td> <td class=\"jobstatus\">%s</td> <td class=\"rescuectr\">%s</td>\\\n", 
                           $insertData, '--', '--', '--', '--', '--';
    $insertData = sprintf "%s  <td class=\"jobid\">%s</td> <td class=\"jobruntime\">%s</td> <td class=\"jobstatus\">%s</td>\\\n", 
                           $insertData, '--', '--', '--';
    $insertData = sprintf "%s  <td class=\"openbox\">%s</td>\\\n", $insertData, '--';

    $insertData = sprintf "%s</tr>\\\n", $insertData;

    $insertData = sprintf "%s<tr>\\\n", $insertData;

    $insertData = sprintf "%s  <td class=\"pipeline\">%s</td> <td class=\"network\">%s</td>\\\n",    
                           $insertData, 'PyGRB+cohPTF', $ifoString;
    $insertData = sprintf "%s  <td class=\"jobid\">%s</td> <td class=\"latency\">%s</td> <td class=\"jobruntime\">%s</td> <td class=\"%s\">%s</td> <td class=\"rescuectr\">%s</td>\\\n",
                           $insertData, $jobId, $latency, $jobRunTime, $jobStatusColor, $jobStatus, $rescueCtr;
    $insertData = sprintf "%s  <td class=\"jobid\">%s</td> <td class=\"jobruntime\">%s</td> <td class=\"jobstatus\">%s</td>\\\n",
                           $insertData, '--', '--', '--';
    $insertData = sprintf "%s  <td class=\"openbox\">%s</td>\\\n", $insertData, '--';
   
    $insertData = sprintf "%s</tr>\n", $insertData;

    #=== Perform sed command ===#
    $sedCommand = sprintf "sed '/%s/a\\%s' %s > %s", $tableInsertTag, $insertData, $htmlFile, $tempFile;
printf "$sedCommand\n";
    system $sedCommand;

    $cpCommand = sprintf "cp %s %s", $tempFile, $htmlFile;
    system $cpCommand;

  }
}


sub grbNotify {

  #use Switch;
  #use strict;
  use warnings;
  use feature qw(switch say);

  my($eheaderRef)  = $_[0];
  my($emailFile)   = $_[1];
  my($messageFile) = $_[2];

  my(@emailList,$tableKey,$fromString,$replyToString,$subjectString,$messageString,
     $emailto,$emailString,$strLength,$catCommand,$mailCommand);

  #=== Open and read file with email addresses and phone numbers ===#
  open EMAILFILE, "<$emailFile"
    or die "Error opening email file $emailFile: $!";
  chomp(@emailList = <EMAILFILE>);
  close EMAILFILE;


  #=== Open files which will contain email message ===# 
  open GRBMESSAGE, ">>$messageFile"
    or die "Error opening message file $messageFile: $!";

  my($messageFileTemp) = sprintf "grbmessage_temp.txt";
  open GRBMESSAGETEMP, ">$messageFileTemp"
    or die "Error opening message file $messageFileTemp: $!";

  #=== Parse email header and message ===#
  $fromString    = '';
  $replyToString = '';
  $subjectString = '';
  $messageString = '';
  foreach $tableKey (keys %$eheaderRef) {
    #switch ($tableKey) {
    #  case 'FROM'    { $fromString    = $eheaderRef->{$tableKey}; }
    #  case 'REPLYTO' { $replyToString = $eheaderRef->{$tableKey}; }
    #  case 'SUBJECT' { $subjectString = $eheaderRef->{$tableKey}; }
    #  case 'MESSAGE' { $messageString = $eheaderRef->{$tableKey}; }
    given ($tableKey) {
      when ('FROM')    { $fromString    = $eheaderRef->{$tableKey}; }
      when ('REPLYTO') { $replyToString = $eheaderRef->{$tableKey}; }
      when ('SUBJECT') { $subjectString = $eheaderRef->{$tableKey}; }
      when ('MESSAGE') { $messageString = $eheaderRef->{$tableKey}; }
    }
  }

  if ($fromString eq '') {
#    $fromString = sprintf "XPipeline <xpipeline\@ldas-grid.ligo.caltech.edu>";
     $fromString = sprintf "ExtTrig <grb.exttrig\@ldas-grid.ligo.caltech.edu>";
  }
  if ($replyToString eq '') {
    $replyToString = sprintf "Dipongkar Talukder <talukder\@uoregon.edu>";
  }
  if ($subjectString eq '') {
    $subjectString = sprintf "[grbonline]";
  }
  if ($messageString eq '') {
    return;
  }


  $emailString = "To:";
  foreach $emailto (@emailList) {
    $emailString = sprintf "%s %s,", $emailString, $emailto;
  }
  $strLength = length($emailString);
  $emailString   = substr($emailString,0,$strLength-1);

  printf GRBMESSAGETEMP "%s\n", $emailString;
  printf GRBMESSAGETEMP "From: %s\n", $fromString;
  printf GRBMESSAGETEMP "Reply-to: %s\n", $replyToString;
  printf GRBMESSAGETEMP "Subject: %s\n", $subjectString;
  printf GRBMESSAGETEMP "%s\n", $messageString;

  $timeString = localtime;
  printf GRBMESSAGE "\nDate: %s Pacific\n", $timeString;

  close GRBMESSAGETEMP;
  close GRBMESSAGE;

  $catCommand = sprintf "cat %s >> %s", $messageFileTemp, $messageFile;
  system $catCommand;

  $mailCommand = sprintf "sendmail -t < %s", $messageFileTemp;
  printf "$mailCommand\n";
  system $mailCommand;

}

sub createGrbNotes {

  my($grbName)      = $_[0];
  my($grbGPS)       = $_[1];
  my($grbDate)      = $_[2];
  my($grbTime)      = $_[3];
  my($grbHttp)      = $_[4];
  my($grbRA)        = $_[5];
  my($grbDec)       = $_[6];
  my($grbError)     = $_[7];
  my($PUBLICDIR)    = $_[8];

  my($notesTemplate) = sprintf "%s/grbnotes_template.html", $PUBLICDIR;

  #=== Specify placeholder tags ===#
  my($gcnTag)       = 'GCNNUM';
  my($satelliteTag) = 'TRIGSAT';
  my($dateTag)      = 'GRBDATE';
  my($timeTag)      = 'GRBTIME';
  my($raTag)        = 'GRBRA';
  my($decTag)       = 'GRBDEC';
  my($errTag)       = 'POSERR';

  chomp($grbGPS);

  my($notesHtml) = sprintf "%s/grb%s_notes.html", $PUBLICDIR, $grbName;
  my($tempFile)  = sprintf "%s.temp", $notesHtml;

  #=== If notes file already exists, no need to do anything ===#
  if (-e $notesHtml) {
    return;
  }

  my($cpCommand) = sprintf "cp %s %s", $notesTemplate, $notesHtml;
  system $cpCommand;

  #=== Update GRB notes ===#
  my($sedCommand) = sprintf "sed -e 's/%s/%s <a href=\"%s\">%d<\\/a>/' \\
                                 -e 's/%s/%s/' \\
                                 -e 's/%s/%s/' -e 's/%s/%s %10.0f/' \\
                                 -e 's/%s/%s/' -e 's/%s/%s/' \\
                                 -e 's/%s/%.2f %s/' %s > %s",
                                       $gcnTag, $gcnTypeString, $mainLink, $gcnNum,
                                       $satelliteTag, $satellite,
                                       $dateTag, $grbName,
                                       $timeTag, $grbUT, $grbGPS,
                                       $raTag, $grbRA,
                                       $decTag, $grbDec,
                                       $errTag, $grbError, $posErrorCode,
                                       $notesHtml, $tempFile;
  printf "$sedCommand\n";
  system $sedCommand;

  $cpCommand = sprintf "cp %s %s", $tempFile, $notesHtml;
  system $cpCommand;

  my($rmCommand) = sprintf "rm %s", $tempFile;
  system $rmCommand;
}

sub findGrbLinks {

  my($grbName)    = $_[0];
  my($aliasValue) = $_[1];
  my($PUBLICDIR)  = $_[2];

  my($htmlLine,$gcnGrb,$gcn3Num,$gcnLink,$linkText,$sedCommand,$lineNumber);

  my($GCNURL)    = sprintf "http:\\/\\/gcn.gsfc.nasa.gov";
  my($notesHtml) = sprintf "%s/grb%s_notes.html", $PUBLICDIR, $grbName;
  my($tempFile)  = sprintf "%s.temp", $notesHtml;
  my($linksTag)  = 'Insert links below';

  my($cpCommand) = sprintf "cp %s %s", $tempFile, $notesHtml;
  my($rmCommand) = sprintf "rm %s", $tempFile;

  if (! -e $notesHtml) {
    printf "GRB notes file $notesHtml does not exist.\n";
    return;
  }

  #=== Look for related links for this GRB ===#
  my($gcnArchive)  = sprintf "gcn3_archive.html";
  my($wgetCommand) = sprintf " wget -N http://gcn.gsfc.nasa.gov/%s", $gcnArchive;
  system $wgetCommand;

  open GCN, "<$gcnArchive"
    or die "Error opening input GCN archive file $gcnArchive: $!";

  my(@htmlLines) = ();
  chomp(@htmlLines = <GCN>);
  close GCN;

  if ($aliasValue ne '') {
    $grbName = $aliasValue;
  }

  if ($grbName =~ /[aA]/) {
    $grbName = substr($grbName,0,6);
  }

  @htmlLines = reverse(@htmlLines);

  foreach $htmlLine (@htmlLines) {
    if ($htmlLine =~ /(\d{6,9})([a-z])?(.*)<br>/i) {
      $gcnGrb   = $1.uc($2);
      #$gcnTitle = $gcnGrb.$3;
      if ($gcnGrb =~ /A/) {
        $gcnGrb = substr($gcnGrb,0,6);
      }
      if (uc($gcnGrb) eq  uc($grbName)) {
        if ($htmlLine =~ /gcn3\/(\d+)\.gcn3>(\d+)<\/A>(.*)<br>/) {
          $gcn3Num    = $1;
          $gcnTitle   = $3;
          $gcnLink    = sprintf "%s\\/gcn3\\/%s.gcn3", $GCNURL, $gcn3Num;
          $linkText   = sprintf "GCN Circular %s", $gcn3Num;

          #=== Check if this link is already in the file ===#
          $sedCommand = sprintf "sed -n '/%s/=' %s", $linkText, $notesHtml;
          $lineNumber = -1;
          $lineNumber = `$sedCommand`;
          chomp($lineNumber);

          #=== If link is not yet in the file ===#
          if (! $lineNumber =~ /^[1-11]/) {
            $sedCommand = sprintf "sed '/%s/a <a href=\"%s\">%s</a>%s<br />' %s > %s",
                                         $linksTag, $gcnLink, $linkText, $gcnTitle, $notesHtml, $tempFile;
            system $sedCommand;
            system $cpCommand;
            system $rmCommand;
          } else {
            printf "Link already exists: $linkText\n";
          }
        }
      }
    }
  }
}
1;
