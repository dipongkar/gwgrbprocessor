from ligo.gracedb.rest import GraceDb, HTTPError

gracedb = GraceDb()
graceid = 'EVENT_ID'
message = 'Online PyGRB off-source results: see <a href="PUBSERVER/~USERNAME/grb/online/LIGORUN/GRBEVENT_ID/GRBEVENT_ID_CLOSED/summary.html">here</a>.'
try:
  r = gracedb.writeLog(graceid,message,tagname="ext_coinc")
  print "Response status: %d" % r.status
except HTTPError, e:
  print "Something's wrong: %s" % str(e)
