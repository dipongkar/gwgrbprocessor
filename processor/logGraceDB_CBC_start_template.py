from ligo.gracedb.rest import GraceDb, HTTPError

gracedb = GraceDb()
graceid = 'EVENT_ID'
message = 'Online PyGRB launched, HOUR hours after the trigger (IFO in science: NETWORK)'
try:
  r = gracedb.writeLog(graceid,message)
  print "Response status: %d" % r.status
except HTTPError, e:
  print "Something's wrong: %s" % str(e)
