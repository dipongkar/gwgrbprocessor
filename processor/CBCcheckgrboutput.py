#!/usr/bin/env python

"""
Checks existence of output files of coh-PTF as run using lalapps_trigger_hipe
$Id$
"""


# -------------------------------------------------------------------------
#      Setup.
# -------------------------------------------------------------------------

# ---- Import standard modules to the python path.
import sys, os, commands
from optparse import OptionParser

# ---- Function usage.
def usage():
  msg = """\
Usage: 
  CBCcheckgrboutput.py [options]
  -d, --grb-dir <path>        path of GRB dir 
  -t, --tmp-dir <path>        path of temporary dir

e.g.,
  CBCcheckgrboutput.py -t /usr1/dtalukder/log/dtalukder/pegasus/pygrb/run0001 -g /home/dtalukder/PyGRB/runs/test_may012015/GRBE124599 -j inspiral
"""
  print >> sys.stderr, msg


# -------------------------------------------------------------------------
#      Parse the command line options.
# -------------------------------------------------------------------------
parser = OptionParser()

parser.add_option("-g", "--grb-dir", dest = "grbdir", type="string",
                  help = "GRB dir",
                  metavar="NAME")
parser.add_option("-t", "--tmp-dir", dest = "tmpdir", type="string",
                  help = "TMP dir",
                  metavar="NAME")
parser.add_option("-j", "--job-type", dest = "jobtype", type="string",
                  help = "JOB type",
                  metavar="NAME")
(options, args) = parser.parse_args()

grb_dir = options.grbdir
tmp_dir = options.tmpdir
job_type = options.jobtype

# ---- Check that all required arguments are specified, else exit.
if not grb_dir:
  print >> sys.stderr, "No grb dir specified."
  print >> sys.stderr, "Use --grb-dir to specify it."
  sys.exit(1)

if not tmp_dir:
  print >> sys.stderr, "No temporary dir specified."
  print >> sys.stderr, "Use --tmp-dir to specify it."
  sys.exit(1)

# ---- assume all files are present
filesMissing  = 0

# ---- check dir names end in '/'
if not(grb_dir.endswith('/')):
   grb_dir = grb_dir + '/'

dirContentsinspiral = os.listdir(grb_dir)

if not(tmp_dir.endswith('/')):
   tmp_dir = tmp_dir + '/'

dirContentsinspiral = os.listdir(grb_dir +'inspiral/')
dirContentsinjections = os.listdir(grb_dir +'injections/')
dirContentsinspiralsub = os.listdir(tmp_dir)
dirContentsPP = os.listdir(grb_dir + 'post_processing/')
dirContentstrigctrsub = os.listdir(tmp_dir)
InspiralFiles = []
InjectionsFiles = []
InspiralsubFiles = []
PPFiles = []
trigctrsubFiles = []

print >> sys.stdout, "Looking for INSPIRAL files in ", grb_dir + 'inspiral/'

for idx in range(len(dirContentsinspiral)):
   if (dirContentsinspiral[idx].startswith('H1L1V1-INSPIRAL') and dirContentsinspiral[idx].endswith('.xml.gz')) or (dirContentsinspiral[idx].startswith('H1L1-INSPIRAL') and dirContentsinspiral[idx].endswith('.xml.gz')) or (dirContentsinspiral[idx].startswith('L1V1-INSPIRAL') and dirContentsinspiral[idx].endswith('.xml.gz')) or (dirContentsinspiral[idx].startswith('H1V1-INSPIRAL') and dirContentsinspiral[idx].endswith('.xml.gz')) or (dirContentsinspiral[idx].startswith('H1-INSPIRAL') and dirContentsinspiral[idx].endswith('.xml.gz')) or (dirContentsinspiral[idx].startswith('L1-INSPIRAL') and dirContentsinspiral[idx].endswith('.xml.gz')) or (dirContentsinspiral[idx].startswith('V1-INSPIRAL') and dirContentsinspiral[idx].endswith('.xml.gz')) and os.path.isfile(grb_dir + 'inspiral/' + dirContentsinspiral[idx]):
      InspiralFiles.append(dirContentsinspiral[idx])

print >> sys.stdout, "Looking for INSPIRAL files in ", grb_dir + 'injections/'

for idx in range(len(dirContentsinjections)):
   if (dirContentsinjections[idx].startswith('H1L1V1-INSPIRAL') and dirContentsinjections[idx].endswith('.xml.gz')) or (dirContentsinjections[idx].startswith('H1L1-INSPIRAL') and dirContentsinjections[idx].endswith('.xml.gz')) or (dirContentsinjections[idx].startswith('L1V1-INSPIRAL') and dirContentsinjections[idx].endswith('.xml.gz')) or (dirContentsinjections[idx].startswith('H1V1-INSPIRAL') and dirContentsinjections[idx].endswith('.xml.gz')) or (dirContentsinjections[idx].startswith('H1-INSPIRAL') and dirContentsinjections[idx].endswith('.xml.gz')) or (dirContentsinjections[idx].startswith('L1-INSPIRAL') and dirContentsinjections[idx].endswith('.xml.gz')) or (dirContentsinjections[idx].startswith('V1-INSPIRAL') and dirContentsinjections[idx].endswith('.xml.gz')) and os.path.isfile(grb_dir + 'injections/' + dirContentsinjections[idx]):
      InjectionsFiles.append(dirContentsinjections[idx])

print >> sys.stdout, "Looking for inspiral*.sub files in ", tmp_dir

#for idx in range(len(dirContentsinspiralsub)):
#   if dirContentsinspiralsub[idx].startswith('inspiral') and dirContentsinspiralsub[idx].endswith('.sub') and os.path.isfile(tmp_dir + dirContentsinspiralsub[idx]):
#      InspiralsubFiles.append(dirContentsinspiralsub[idx])

with open(tmp_dir+'pygrb_offline-0.dag') as dag:
     for lines in dag:
         if lines.lstrip().startswith('JOB inspiral') and lines.rstrip().endswith('.sub'):
            InspiralsubFiles.append('1')

inspiralmissing = len(InspiralsubFiles) - (len(InspiralFiles) + len(InjectionsFiles))

print >> sys.stdout, "Looking for INSPIRAL files in ", grb_dir + 'post_processing/'

for idx in range(len(dirContentsPP)):
   if (dirContentsPP[idx].startswith('H1L1V1-INSPIRAL') and dirContentsPP[idx].endswith('.xml.gz')) or (dirContentsPP[idx].startswith('H1L1-INSPIRAL') and dirContentsPP[idx].endswith('.xml.gz')) or (dirContentsPP[idx].startswith('L1V1-INSPIRAL') and dirContentsPP[idx].endswith('.xml.gz')) or (dirContentsPP[idx].startswith('H1V1-INSPIRAL') and dirContentsPP[idx].endswith('.xml.gz')) or (dirContentsPP[idx].startswith('H1-INSPIRAL') and dirContentsPP[idx].endswith('.xml.gz')) or (dirContentsPP[idx].startswith('L1-INSPIRAL') and dirContentsPP[idx].endswith('.xml.gz')) or (dirContentsPP[idx].startswith('V1-INSPIRAL') and dirContentsPP[idx].endswith('.xml.gz')) and os.path.isfile(grb_dir + 'post_processing/' + dirContentsPP[idx]):
      PPFiles.append(dirContentsPP[idx])

print >> sys.stdout, "Looking for trig_cluster*.sub files in ", tmp_dir

#for idx in range(len(dirContentstrigctrsub)):
#   if dirContentstrigctrsub[idx].startswith('trig_cluster') and dirContentstrigctrsub[idx].endswith('.sub') and os.path.isfile(tmp_dir + dirContentstrigctrsub[idx]):
#      trigctrsubFiles.append(dirContentstrigctrsub[idx])

with open(tmp_dir+'pygrb_offline-0.dag') as dag:
     for lines in dag:
         if lines.lstrip().startswith('JOB trig_cluster') and lines.rstrip().endswith('.sub'):
            trigctrsubFiles.append('1')
print len(trigctrsubFiles)
PPmissing = abs(len(PPFiles) - 2*len(trigctrsubFiles))

if job_type == 'inspiral':
   if inspiralmissing:
       print >> sys.stdout, grb_dir + 'inspiral', ": Number of output inspiral files missing:", inspiralmissing
   else:
       print >> sys.stdout, grb_dir + 'inspiral', ": No output inspiral file missing "
else:
   if PPmissing:
       print >> sys.stdout, grb_dir + 'post_processing', ": Number of output trigcluster files missing:", PPmissing
   else:
       print >> sys.stdout, grb_dir +'post_processing', ": No output trigcluster file missing "

   


















