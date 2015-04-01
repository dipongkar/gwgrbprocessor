import shutil, os, sys
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-g", "--grb-name", dest = "grb_name",
                  help = "GRB-NAME",
                  metavar = "name")
parser.add_option("-s", "--script-dir", dest = "script_dir",
                  help = "SCRIPT-DIR",
                  metavar = "name")
(options, args) = parser.parse_args()

grb = options.grb_name
script = options.script_dir

datafinddir = script+'/runs/CBC/GRB'+grb+'/GRB'+grb+'/datafind/'
dfrepcomm = "perl -pi -e \'s/L1:GDS-FAKE_STRAIN/L1:GDS-CALIB_STRAIN/g\' %s*.dag" %datafinddir
os.system(dfrepcomm)
dfrepcomm = "perl -pi -e \'s/L1:GDS-FAKE_STRAIN/L1:GDS-CALIB_STRAIN/g\' %s*.sh" %datafinddir
os.system(dfrepcomm)

onoffdir = script+'/runs/CBC/GRB'+grb+'/GRB'+grb+'/onoff/'
onoffrepcomm = "perl -pi -e \'s/L1:GDS-FAKE_STRAIN/L1:GDS-CALIB_STRAIN/g\' %scoh_PTF_inspiral.sub" %onoffdir
os.system(onoffrepcomm)
onoffrepcomm = "perl -pi -e \'s/L1:GDS-FAKE_STRAIN/L1:GDS-CALIB_STRAIN/g\' %s*.sh" %onoffdir
os.system(onoffrepcomm)

tsdir = script+'/runs/CBC/GRB'+grb+'/GRB'+grb+'/timeslides/'
tsrepcomm = "perl -pi -e \'s/L1:GDS-FAKE_STRAIN/L1:GDS-CALIB_STRAIN/g\' %scoh_PTF_inspiral.sub" %tsdir
os.system(tsrepcomm)
tsrepcomm = "perl -pi -e \'s/L1:GDS-FAKE_STRAIN/L1:GDS-CALIB_STRAIN/g\' %s*.sh" %tsdir
os.system(tsrepcomm)


