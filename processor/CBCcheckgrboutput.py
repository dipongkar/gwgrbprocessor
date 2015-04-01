#!/usr/bin/env python

"""
Checks existence of output files of coh-PTF as run using lalapps_trigger_hipe
$Id$
"""


# -------------------------------------------------------------------------
#      Setup.
# -------------------------------------------------------------------------

# ---- Import standard modules to the python path.
import sys, os, commands, getopt
import ConfigParser

# ---- Function usage.
def usage():
  msg = """\
Usage: 
  grb.sh [options]
  -d, --grb-dir <path>        path of GRB dir 
  -v, --verbose               use this to have lots of output 
  -h, --help                  display this message and exit

e.g.,
  PTFcheckgrboutput.py -d /home/grb.exttrig/Online/Test_coh_GRB/GRB100515A/GRB100515A
"""
  print >> sys.stderr, msg


# -------------------------------------------------------------------------
#      Parse the command line options.
# -------------------------------------------------------------------------

# ---- Initialise command line argument variables.
params_file = None
grb_list = None
grbscript = None
detector = []
verboseFlag = 0

# ---- Syntax of options, as required by getopt command.
# ---- Short form.
shortop = "hvd:"
# ---- Long form.
longop = [
   "help",
   "verbose",
   "grb-dir=",
   ]

# ---- Get command-line arguments.
try:
  opts, args = getopt.getopt(sys.argv[1:], shortop, longop)
except getopt.GetoptError:
  usage()
  sys.exit(1)

# ---- Parse command-line arguments.  Arguments are returned as strings, so 
#      convert type as necessary.
for o, a in opts:
  if o in ("-h", "--help"):
    usage()
    sys.exit(0)
  elif o in ("-d", "--grb-dir"):
    grb_dir = a      
  elif o in ("-v", "--verbose"):
    verboseFlag = 1      
  else:
    print >> sys.stderr, "Unknown option:", o
    usage()
    sys.exit(1)

# ---- Check that all required arguments are specified, else exit.
if not grb_dir:
  print >> sys.stderr, "No grb dir specified."
  print >> sys.stderr, "Use --grb-dir to specify it."
  sys.exit(1)

if verboseFlag:
    # ---- Status message.  Report all supplied arguments.
    print >> sys.stdout
    print >> sys.stdout, "####################################################"
    print >> sys.stdout, "#    Checking output of coh-PTF GRB search      #"
    print >> sys.stdout, "####################################################"
    print >> sys.stdout
    print >> sys.stdout, "Parsed input arguments:"
    print >> sys.stdout
    print >> sys.stdout, "             GRB dir:", grb_dir
    print >> sys.stdout

# ---- assume all files are present
filesMissing  = 0

# ---- check dir names end in '/'
if not(grb_dir.endswith('/')):
   grb_dir = grb_dir + '/'

if not os.path.isdir(grb_dir + 'onoff/'): 
   print >> sys.stdout, "Not a valid directory: ", grb_dir + 'onoff/'
   sys.exit()

if not os.path.isdir(grb_dir + 'timeslides/'): 
   print >> sys.stdout, "Not a valid directory: ", grb_dir + 'timeslides/'
   sys.exit()


dirContentsonoff = os.listdir(grb_dir + 'onoff/')
dirContentsTS = os.listdir(grb_dir + 'timeslides/')

OnoffinsFiles = []
TSinsFiles = []
Onoffdag = []
TSdag = []

if verboseFlag:
    print >> sys.stdout, "Looking for COH_PTF_INSPIRAL files in ", grb_dir + 'onoff/'

for idx in range(len(dirContentsonoff)):
   if dirContentsonoff[idx].startswith('H1L1V1-COH_PTF_INSPIRAL') or dirContentsonoff[idx].startswith('H1L1-COH_PTF_INSPIRAL') or dirContentsonoff[idx].startswith('L1V1-COH_PTF_INSPIRAL') or dirContentsonoff[idx].startswith('H1V1-COH_PTF_INSPIRAL') and os.path.isfile(grb_dir + 'onoff/' + dirContentsonoff[idx]):
      OnoffinsFiles.append(dirContentsonoff[idx])
   if dirContentsonoff[idx].endswith('.dag'):
      Onoffdag.append(dirContentsonoff[idx]) 

f1 = open(grb_dir + 'onoff/' + str(Onoffdag).strip('[\' \']'))
contents1 = f1.read()
f1.close()
num1 = contents1.count("PARENT ")

if verboseFlag:
    print >> sys.stdout, "Looking for COH_PTF_INSPIRAL files in ", grb_dir + 'timeslides/'

for idx in range(len(dirContentsTS)):
   if dirContentsTS[idx].startswith('H1L1V1-COH_PTF_INSPIRAL') or dirContentsTS[idx].startswith('H1L1-COH_PTF_INSPIRAL') or dirContentsTS[idx].startswith('L1V1-COH_PTF_INSPIRAL') or dirContentsTS[idx].startswith('H1V1-COH_PTF_INSPIRAL') and os.path.isfile(grb_dir + 'timeslides/' + dirContentsTS[idx]):
      TSinsFiles.append(dirContentsTS[idx])
   if dirContentsTS[idx].endswith('.dag'):
      TSdag.append(dirContentsTS[idx]) 

f2 = open(grb_dir + 'timeslides/' + str(TSdag).strip('[\' \']'))
contents2 = f2.read()
f2.close()
num2 = contents2.count("PARENT ")


filesMissing1 = num1 - len(OnoffinsFiles)
filesMissing2 = num2 - len(TSinsFiles)

if filesMissing1:
   print >> sys.stdout, grb_dir + 'onoff/', " :Number of output files missing: ", filesMissing1
else:
   print >> sys.stdout, grb_dir + 'onoff/', " :No output files missing"

if filesMissing2:
   print >> sys.stdout, grb_dir + 'timeslides/', " :Number of output files missing: ", filesMissing2
else:
   print >> sys.stdout, grb_dir + 'timeslides/', " :No output files missing"


print >> sys.stdout, "Checking onoff log dir for errors with coh-PTF jobs ..."
errCommand1 = 'ls --time-style=long-iso -al ' + grb_dir +  'onoff/logs/coh_PTF_inspiral*.err | awk \'{if ($5 > 0) print $5 " " $8}\' '
os.system(errCommand1)

print >> sys.stdout, "Checking timeslides log dir for errors with coh-PTF jobs ..."
errCommand2 = 'ls --time-style=long-iso -al ' + grb_dir +  'timeslides/logs/coh_PTF_inspiral*.err | awk \'{if ($5 > 0) print $5 " " $8}\' '
os.system(errCommand2)

if verboseFlag:
    print >> sys.stdout
    print >> sys.stdout, " ... finished."

print >> sys.stdout, " " 
