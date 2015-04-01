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
    #=== If science run is post-S5 use new segment commands ===#
#    if ($runNumber > 5) {
    #  $segFindCommand = sprintf "ligolw_dq_query --segment %s --include-segments %s:%s", $dataServer, $ifo, uc(@$segmentType[$iifo]);
    #  $segFindCommand = sprintf "%s --report %d --start-pad %d --end-pad %d", $segFindCommand, $gpsGPS, $startPad, $endPad;
     # `S6_SEGMENT_SERVER=https://segdb-er.ligo.caltech.edu`;
#      $segFindCommand = sprintf "ligolw_segment_query --segment %s --include-segments %s:%s", $dataServer, $ifo, uc(@$segmentType[$iifo]);
      $segFindCommand = sprintf "ligolw_segment_query_dqsegdb --segment %s --include-segments %s:%s", $dataServer, $ifo, uc(@$segmentType[$iifo]);
      $segFindCommand = sprintf "%s --gps-start-time %d --gps-end-time %d --query-segments", $segFindCommand, $gpsStart, $gpsEnd;
#    } else {
#      $segFindCommand = sprintf "LSCsegFind --server=%s --interferometer %s --type %s", $dataServer, $ifo, @$segmentType[$iifo];
#      $segFindCommand = sprintf "%s --gps-start-time %d --gps-end-time %d", $segFindCommand, $gpsStart, $gpsEnd;
#    }

    printf "$segFindCommand\n";

    @segResults = ();
    @segResults = `$segFindCommand`;
    chomp(@segResults);

    #foreach $segResult (@segResults) {
    #  printf "$segResult\n";
    #}

    $invalidSegmentFlag = 0;
    #=== If science run is post-S5 use new segment commands ===#
#    if ($runNumber > 5) {
      my($segStartRef,$segEndRef,$totalSegDuration) = parseSegmentsXml(\@segResults);
      my(@segGpsStart) = @$segStartRef;
      my(@segGpsEnd)   = @$segEndRef;
      #if ($#segResults + 1 == 1) {
      #  if ($segResults[0] =~ /[.*)/) {
      #    push(@netIfos,$ifo);
      #  }
      #}
      if ($#segGpsStart + 1 == 1 && $totalSegDuration >= $minDuration) {
        push(@netIfos,$ifo);
      }
#    } else {
#      if ($#segResults + 1 > 0) {
#        foreach $segResult (@segResults) {
#          ($segStart,$segEnd) = split(/ /,$segResult);
#          if ($segEnd - $segStart < $searchDuration) {
#            $invalidSegmentFlag = 1;
#            last;
#          }
#        }
#        if ($invalidSegmentFlag == 0) {
#          push(@netIfos,$ifo);
#        }
#      }
#    }
    $iifo++;
  }
  return @netIfos;
}

sub querySegments {

  use Switch;

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
    switch ($ifo) {
      case 'H1'
      {
        $inet = 0;
      }
      case 'L1'
      {
        $inet = 1;
      }
#      case 'V1'
#      {
#        $inet = 2;
#      }
    }
    $segmentFlag[$iifo] = 0;
    #=== If science run is post-S5 use new segment commands ===#
#    if ($runNumber > 5) {
    #  $segFindCommand = sprintf "ligolw_dq_query --segment %s --include-segments %s:%s", $dataServer, $ifo, uc(@$segmentType[$inet]);
    #  $segFindCommand = sprintf "%s --report %d --start-pad %d --end-pad %d", $segFindCommand, $gpsGPS, $startPad, $endPad;
     # `S6_SEGMENT_SERVER=https://segdb-er.ligo.caltech.edu`;
#      $segFindCommand = sprintf "ligolw_segment_query --segment %s --include-segments %s:%s", $dataServer, $ifo, uc(@$segmentType[$inet]);
      $segFindCommand = sprintf "ligolw_segment_query_dqsegdb --segment %s --include-segments %s:%s", $dataServer, $ifo, uc(@$segmentType[$inet]);
      $segFindCommand = sprintf "%s --gps-start-time %d --gps-end-time %d --query-segments", $segFindCommand, $gpsStart, $gpsEnd;
#    } else {
#      $segFindCommand = sprintf "LSCsegFind --server=%s --interferometer %s --type %s", $dataServer, $ifo, @$segmentType[$inet];
#      $segFindCommand = sprintf "%s --gps-start-time %d --gps-end-time %d", $segFindCommand, $gpsStart, $gpsEnd;
#    }

    printf "$segFindCommand\n";

    @segResults = ();
    @segResults = `$segFindCommand`;
    chomp(@segResults);

    $invalidSegmentFlag = 0;
    #=== If science run is post-S5 use new segment commands ===#
#    if ($runNumber > 5) {
      my($segStartRef,$segEndRef,$totalSegDuration) = parseSegmentsXml(\@segResults);
      my(@segGpsStart) = @$segStartRef;
      my(@segGpsEnd)   = @$segEndRef;
      #if ($#segResults + 1 == 1) {
      #  if ($segResults[0] =~ /[.*)/) {
      #    push(@netIfos,$ifo);
      #  }
      #}
      if ($totalSegDuration >= $minDuration) {
        $segmentFlag[$iifo] = 1;
        if ($writeSegsFlag == 1) {
          &writeSegments($jobDir,$ifo,\@segGpsStart,\@segGpsEnd);
        }
      }
#    } else {
#      if ($#segResults + 1 > 0) {
#        foreach $segResult (@segResults) {
#          ($segStart,$segEnd) = split(/ /,$segResult);
#          if ($segEnd - $segStart < $searchDuration) {
#            $invalidSegmentFlag = 1;
#            last;
#          }
#        }
#        if ($invalidSegmentFlag == 0) {
#          push(@netIfos,$ifo);
#        }
#      }
#    }
    $iifo++;
  }
  return @segmentFlag;
}

sub parseSegmentsXml {

  my($xmlTable) = $_[0];

# (20130922)
#  my($streamStart) = 'Stream Name="segment:table"';  
# (20140506) 
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
 
  use Switch;

  my($netIfosRef)      = $_[0];
  my($jobDir)          = $_[1];
  my($iniTemplateFile) = $_[2];
  my($iniFile)         = $_[3];
  my($lagFileToken)    = $_[4];
  my($likelihoodToken) = $_[5];

  my($ifoString,$ifo,$lagFile,$likelihoodType,$nifos,$sedCommand);

  my(@netIfos) = @$netIfosRef;

  $ifoString = '';
  foreach $ifo (@netIfos) {
    $ifoString = "$ifoString"."$ifo";
  }

  $lagFile        = '';
  $likelihoodType = '';
  $nifos = $#netIfos+1;
  switch ($nifos) {
    case 2
    {
      if ($ifoString =~ /H1/i && $ifoString =~ /H2/i) {
        $lagFile = '2det1site';
        $likelihoodType = 'plusenergy,plusinc,nullenergy,nullinc';
      } else {
        $lagFile = '2det2site';
        $likelihoodType = 'standard,plusenergy,plusinc,crossenergy,crossinc';
      }
   }

    case 3
    {
      if ($ifoString =~ /H1/i && $ifoString =~ /H2/i) {
        $lagFile = '3det2site';
        $likelihoodType = 'standard,plusenergy,plusinc,crossenergy,crossinc,nullenergy,nullinc';
      } else {
        $lagFile = '3det3site';
        $likelihoodType = 'standard,plusenergy,plusinc,crossenergy,crossinc,nullenergy,nullinc';
      }
    }

    case 4
    {
      $lagFile = '4det3site';
      $likelihoodType = 'standard,plusenergy,plusinc,crossenergy,crossinc,nullenergy,nullinc,H1H2nullenergy,H1H2nullinc';
    }

    else
    {
      return $ifoString;
    }
  }

#=== This block is commented out because of changes to grb.py ===#
#  $sedCommand = sprintf "sed -e '/^lagFile.*/s/%s/%s/' -e '/^likelihoodType.*/s/%s/%s/' -e '/^segmentListFile.*/s/jobdir/%s/' %s > %s",
#                         $lagFileToken, $lagFile, $likelihoodToken, $likelihoodType, $jobDir,
#                         $iniTemplateFile, $iniFile;
#printf "$sedCommand\n";
#
#  system $sedCommand;

  $cpCommand = sprintf "cp %s %s", $iniTemplateFile, $iniFile;
  system $cpCommand;

  return $ifoString;

}

sub updateWebStatus {

  use Switch;

  my($statusTableRef) = $_[0];
  my($htmlFile)       = $_[1];
  my($lineOffset)     = $_[2];
  my($resultsLink)    = $_[3];
  my($openboxLink)    = $_[4];

# my(%searchStatusTable) = %$statusTableRef;
  my($searchStatusTable) = $statusTableRef;

  my($tableKey,$tempFile,$tableInsertTag,$insertData,$sedCommand,$lineNumber,$htmlString,$cpCommand);
  my($grbName,$grbGPS,$grbDate,$grbTime,$grbRA,$grbDec,$grbError,$ifoString,$grbSat,$jobId,$latency,$jobRunTime,$jobStatus,$rescueCtr,$jobStatusColor);

  $tempFile = sprintf "%s.temp", $htmlFile;

  $tableInsertTag = 'Insert new GRBs here';

  $rescueCtr = -1;

  foreach $tableKey (keys %$searchStatusTable) {
    #printf "%s %s\n", $tableKey, $searchStatusTable->{$tableKey};
    switch ($tableKey) {
      case 'GRB_NAME'      { $grbName    = $searchStatusTable->{$tableKey}; }
      case 'GRB_GPS'       { $grbGPS     = $searchStatusTable->{$tableKey}; }
      case 'GRB_DATE'      { $grbDate    = $searchStatusTable->{$tableKey}; }
      case 'GRB_TIME'      { $grbTime    = $searchStatusTable->{$tableKey}; }
      case 'GRB_RA'        { $grbRA      = $searchStatusTable->{$tableKey}; }
      case 'GRB_DEC'       { $grbDec     = $searchStatusTable->{$tableKey}; }
      case 'GRB_ERR'       { $grbError   = $searchStatusTable->{$tableKey}; }
      case 'IFO_STRING'    { $ifoString  = $searchStatusTable->{$tableKey}; }
      case 'GRB_SAT'       { $grbSat     = $searchStatusTable->{$tableKey}; }
      case 'JOB_CLUSTER'   { $jobId      = $searchStatusTable->{$tableKey}; }
      case 'LATENCY'       { $latency    = $searchStatusTable->{$tableKey}; }
      case 'RUN_TIME'      { $jobRunTime = $searchStatusTable->{$tableKey}; }
      case 'JOB_STATUS'    { $jobStatus  = $searchStatusTable->{$tableKey}; }
      case 'RESCUE_CTR'    { $rescueCtr  = $searchStatusTable->{$tableKey}; }
    }
  }

  #=== Specify job status color ===#
  switch ($jobStatus) {
    case 'PROCESSED' { $jobStatusColor = "jobstatus"; }
    case 'RUNNING'   { $jobStatusColor = "jobrun"; }
    case 'SUBMITTED' { $jobStatusColor = "jobsubmit"; }
    case 'DATACUT'   { $jobStatusColor = "jobcut"; }
    case 'IDLE'      { $jobStatusColor = "jobidle"; }
    case 'HELD'      { $jobStatusColor = "jobheld"; }
    else             { $jobStatusColor = "jobfail"; }
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
#           "  <td class=\"grbra\" rowspan=\"2\">%s<\\/td> <td class=\"grbdec\" rowspan=\"2\">%s<\\/td> <td class=\"grberr\" rowspan=\"2\">%s<\\/td> <td class=\"pipeline\">%s<\\/td> <td class=\"network\">%s<\\/td>\\\n",
#                      $grbRA, $grbDec, $grbError, 'X-pipeline', $ifoString;
        $htmlString = sprintf 
           "  <td class=\"jobid\">%s<\\/td> <td class=\"jobruntime\">%s<\\/td> <td class=\"%s\">%s<\\/td>",
                      $jobId, $jobRunTime, $jobStatusColor, $jobStatus;
      } else {
#        $htmlString = sprintf
#           "  <td class=\"grbra\" rowspan=\"2\">%s<\\/td> <td class=\"grbdec\" rowspan=\"2\">%s<\\/td> <td class=\"grberr\" rowspan=\"2\">%s<\\/td> <td class=\"pipeline\">%s<\\/td> <td class=\"network\">%s<\\/td>\\\n",
#                      $grbRA, $grbDec, $grbError, 'X-pipeline', $ifoString;
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

    $insertData = sprintf "%s  <td class=\"grbname\" rowspan=\"2\"><a href=\"https://gracedb.ligo.org/events/%s\">%s</a></td> <td class=\"grbsat\" rowspan=\"2\">%s</td> <td class=\"grbdate\" rowspan=\"2\">%s, %s</td> <td class=\"grbgps\" rowspan=\"2\">%s</td>\\\n", 
                           $insertData, $grbName, $grbName, $grbSat, $grbDate, $grbTime, $grbGPS;
    $insertData = sprintf "%s  <td class=\"grbra\" rowspan=\"2\">%s</td> <td class=\"grbdec\" rowspan=\"2\">%s</td> <td class=\"grberr\" rowspan=\"2\">%s</td>\\\n", 
                           $insertData, $grbRA, $grbDec, $grbError;
    $insertData = sprintf "%s  <td class=\"pipeline\">%s</td> <td class=\"network\">%s</td>\\\n",
                           $insertData, 'X-pipeline', $ifoString;
    $insertData = sprintf "%s  <td class=\"jobid\">%s</td> <td class=\"latency\">%s</td> <td class=\"jobruntime\">%s</td> <td class=\"%s\">%s</td> <td class=\"rescuectr\">%s</td>\\\n", 
                           $insertData, $jobId, $latency, $jobRunTime, $jobStatusColor, $jobStatus, $rescueCtr;
    $insertData = sprintf "%s  <td class=\"jobid\">%s</td> <td class=\"jobruntime\">%s</td> <td class=\"jobstatus\">%s</td>\\\n", 
                           $insertData, '--', '--', '--';
    $insertData = sprintf "%s  <td class=\"openbox\">%s</td>\\\n", $insertData, '--';

    $insertData = sprintf "%s</tr>\\\n", $insertData;

    $insertData = sprintf "%s<tr>\\\n", $insertData;

    $insertData = sprintf "%s  <td class=\"pipeline\">%s</td> <td class=\"network\">%s</td>\\\n",    
                           $insertData, 'cohPTF', '--';
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

  use Switch;

  my($statusTableRef) = $_[0];
  my($htmlFile)       = $_[1];
  my($lineOffset)     = $_[2];
  my($resultsLink)    = $_[3];
  my($openboxLink)    = $_[4];

# my(%searchStatusTable) = %$statusTableRef;
  my($searchStatusTable) = $statusTableRef;

  my($tableKey,$tempFile,$tableInsertTag,$insertData,$sedCommand,$lineNumber,$htmlString,$cpCommand);
  my($grbName,$grbGPS,$grbDate,$grbTime,$grbRA,$grbDec,$grbError,$ifoString,$grbSat,$jobId,$latency,$jobRunTime,$jobStatus,$rescueCtr,$jobStatusColor);

  $tempFile = sprintf "%s.temp", $htmlFile;

  $tableInsertTag = 'Insert new GRBs here';

  $rescueCtr = -1;

  foreach $tableKey (keys %$searchStatusTable) {
    #printf "%s %s\n", $tableKey, $searchStatusTable->{$tableKey};
    switch ($tableKey) {
      case 'GRB_NAME'      { $grbName    = $searchStatusTable->{$tableKey}; }
      case 'GRB_GPS'       { $grbGPS     = $searchStatusTable->{$tableKey}; }
      case 'GRB_DATE'      { $grbDate    = $searchStatusTable->{$tableKey}; }
      case 'GRB_TIME'      { $grbTime    = $searchStatusTable->{$tableKey}; }
      case 'GRB_RA'        { $grbRA      = $searchStatusTable->{$tableKey}; }
      case 'GRB_DEC'       { $grbDec     = $searchStatusTable->{$tableKey}; }
      case 'GRB_ERR'       { $grbError   = $searchStatusTable->{$tableKey}; }
      case 'IFO_STRING'    { $ifoString  = $searchStatusTable->{$tableKey}; }
      case 'GRB_SAT'       { $grbSat     = $searchStatusTable->{$tableKey}; }
      case 'JOB_CLUSTER'   { $jobId      = $searchStatusTable->{$tableKey}; }
      case 'LATENCY'       { $latency    = $searchStatusTable->{$tableKey}; }
      case 'RUN_TIME'      { $jobRunTime = $searchStatusTable->{$tableKey}; }
      case 'JOB_STATUS'    { $jobStatus  = $searchStatusTable->{$tableKey}; }
      case 'RESCUE_CTR'    { $rescueCtr  = $searchStatusTable->{$tableKey}; }
    }
  }

  #=== Specify job status color ===#
  switch ($jobStatus) {
    case 'PROCESSED' { $jobStatusColor = "jobstatus"; }
    case 'RUNNING'   { $jobStatusColor = "jobrun"; }
    case 'SUBMITTED' { $jobStatusColor = "jobsubmit"; }
    case 'DATACUT'   { $jobStatusColor = "jobcut"; }
    case 'IDLE'      { $jobStatusColor = "jobidle"; }
    case 'HELD'      { $jobStatusColor = "jobheld"; }
    else             { $jobStatusColor = "jobfail"; }
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
               'cohPTF', $ifoString;
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
#        $htmlString = sprintf
#           " <td class=\"pipeline\">%s<\\/td> <td class=\"network\">%s<\\/td>\\\n",
#                      'cohPTF', $ifoString;
        $htmlString = sprintf 
           "  <td class=\"jobid\">%s<\\/td> <td class=\"jobruntime\">%s<\\/td> <td class=\"%s\">%s<\\/td>",
                      $jobId, $jobRunTime, $jobStatusColor, $jobStatus;
##        $htmlString = sprintf
##            "  <td class=\"pipeline\">%s<\\/td> <td class=\"network\">%s<\\/td> <td class=\"jobid\">%s<\\/td> <td class=\"jobruntime\">%s<\\/td> <td class=\"%s\">%s<\\/td>",
##                 'cohPTF', $ifoString, $jobId, $jobRunTime, $jobStatusColor, $jobStatus;
      } else {
#        $htmlString = sprintf
#            " <td class=\"pipeline\">%s<\\/td> <td class=\"network\">%s<\\/td>\\\n",
#                      'cohPTF', $ifoString;
        $htmlString = sprintf 
           "  <td class=\"jobid\">%s<\\/td> <td class=\"latency\">%s<\\/td> <td class=\"jobruntime\">%s<\\/td> <td class=\"%s\">%s<\\/td> <td class=\"rescuectr\">%s<\\/td>",
                     $jobId, $latency, $jobRunTime, $jobStatusColor, $jobStatus, $rescueCtr;
##         $htmlString = sprintf
##             "  <td class=\"pipeline\">%s<\\/td> <td class=\"network\">%s<\\/td> <td class=\"jobid\">%s<\\/td> <td class=\"jobruntime\">%s<\\/td> <td class=\"%s\">%s<\\/td> <td class=\"rescuectr\">%s<\\/td>",
##                    'cohPTF', $ifoString, $jobId, $jobRunTime, $jobStatusColor, $jobStatus, $rescueCtr;
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

    $insertData = sprintf "%s  <td class=\"grbname\" rowspan=\"2\"><a href=\"https://gracedb.ligo.org/events/%s\">%s</a></td> <td class=\"grbsat\" rowspan=\"2\">%s</td> <td class=\"grbdate\" rowspan=\"2\">%s, %s</td> <td class=\"grbgps\" rowspan=\"2\">%s</td>\\\n", 
                           $insertData, $grbName, $grbName, $grbSat, $grbDate, $grbTime, $grbGPS;
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
                           $insertData, 'cohPTF', $ifoString;
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

  use Switch;

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
    switch ($tableKey) {
      case 'FROM'    { $fromString    = $eheaderRef->{$tableKey}; }
      case 'REPLYTO' { $replyToString = $eheaderRef->{$tableKey}; }
      case 'SUBJECT' { $subjectString = $eheaderRef->{$tableKey}; }
      case 'MESSAGE' { $messageString = $eheaderRef->{$tableKey}; }
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

#  my($satelliteCode) = $satellite;
#  if ($satellite eq 'SwiftSub') {
#    $satelliteCode = 'Swift';
#  }
#  if ($satellite eq 'SuperAGILE') {
#    $satilliteCode = 'AGILE';
#  }

#  my($posErrorCode) = '(undefined)';
#  if ($grbErrorType eq 'stat') {
#    $posErrorCode = '(statistical only)';
#  } else {
#    if ($grbErrorType eq 'ssys') {
#      $posErrorCode = '(statistical plus systematic)';
#    }
#  }

#  if ($gcnType eq 'N') {
#    $gcnTypeString = 'Notice';
#    $mainLink      = sprintf "%s\\/%d.%s", $GCNBASE, $gcnNum, lc($satelliteCode);
#  } else {
#    if ($gcnType eq 'C') {
#      $gcnTypeString = 'Circular';
#      $mainLink      = sprintf "%s\\/gcn3\\/%d.gcn3", $GCNURL, $gcnNum;
#    } else {
#      printf "Invalid GCN type $gcnType for GRB $grbName.\n";
#      return;
#    }
#  }

  #=== Calculate GPS time ===#
#  my($tconvertCommand) = sprintf "tconvert %s %s UT", substr($grbName,0,6), $grbUT;
#  my($grbGPS) = `$tconvertCommand`;
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
