from ligo.gracedb.rest import GraceDb, HTTPError

gracedb = GraceDb()
graceid = 'EVENT_ID'
message = 'cohPTF results: FAP = FAP_VAL for M_chirp in [0,8]. For full results, see <a href="https://ldas-jobs.ligo.caltech.edu/~grb.exttrig/grb/online/preER7/GRBEVENT_ID/OPEN_summary.html">here</a>.'
try:
  r = gracedb.writeLog(graceid,message,tagname="ext_coinc")
  print "Response status: %d" % r.status
except HTTPError, e:
  print "Something's wrong: %s" % str(e)
