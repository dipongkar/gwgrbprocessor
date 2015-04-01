import shutil
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-g", "--grb-name", dest = "grb_name",
                  help = "GRB-NAME",
                  metavar = "name")
parser.add_option("-s", "--script-dir", dest = "script_dir",
                  help = "SCRIPT-DIR",
                  metavar = "name")
parser.add_option("-r", "--ligo-run", dest = "ligo_run",
                  help = "LIGO-RUN",
                  metavar = "name")

(options, args) = parser.parse_args()

grb = options.grb_name
script = options.script_dir
run = options.ligo_run

shutil.copytree(script+'/runs/CBC/GRB'+grb+'/GRB'+grb+'/post_processing/output', '/home/grb.exttrig/public_html/grb/online/'+run+'/GRB'+grb)

