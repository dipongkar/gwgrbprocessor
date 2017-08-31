from ligo.gracedb.rest import GraceDb, HTTPError

gracedb = GraceDb()
graceid = 'EVENT_ID'
message = 'Online PyGRB analysis complete, HOUR hours after the trigger'
try:
    r = gracedb.writeLog(graceid, message)
    print "Response status: %d" % r.status
except HTTPError, e:
    print "Something's wrong: %s" % str(e)
