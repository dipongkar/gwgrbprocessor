from optparse import OptionParser
import os, shutil


parser = OptionParser()

parser.add_option("-f", "--copyfrom", dest = "copyFrom", type="string",
                  help = "Copy web file from",
                  metavar="NAME")
parser.add_option("-t", "--copyto", dest = "copyTo", type="string",
                  help = "Copy web file to",
                  metavar="NAME")
(options, args) = parser.parse_args()

copyfrom = options.copyFrom
copyto = options.copyTo

webfile = os.stat(copyfrom)
file_size = webfile.st_size
if file_size > 10:
    shutil.copy2(copyfrom,copyto)
    print "Done"
else:
    print "File is empty"


