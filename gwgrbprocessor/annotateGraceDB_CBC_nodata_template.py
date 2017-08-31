from ligo.gracedb.rest import GraceDb, HTTPError

gracedb = GraceDb()
graceid = 'EVENT_ID'
message = 'Online PyGRB cannot be launched'
try:
    r = gracedb.writeLog(graceid, message, tagname="ext_coinc")
    print "Response status: %d" % r.status
except HTTPError, e:
    print "Something's wrong: %s" % str(e)
