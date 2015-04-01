from ligo.gracedb.rest import GraceDb, HTTPError

gracedb = GraceDb()
graceid = 'EVENT_ID'
message = 'X-pipeline results: No surviving event. For full results, see <a href="https://ldas-jobs.ligo.caltech.edu/~grb.exttrig/grb/online/preER7/search/results/EVENT_ID_online/EVENT_ID_online_openbox.shtml">here</a>.'
try:
  r = gracedb.writeLog(graceid,message,tagname="ext_coinc")
  print "Response status: %d" % r.status
except HTTPError, e:
  print "Something's wrong: %s" % str(e)
