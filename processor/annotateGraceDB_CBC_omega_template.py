from ligo.gracedb.rest import GraceDb, HTTPError

gracedb = GraceDb()
graceid = 'EVENT_ID'
message = 'Omega scan for the loudest on-source PyGRB event, see <a href="PUBSERVER/~USERNAME/wdq/LIGORUN/IFO_GPS">here</a> for IFO.'
try:
  r = gracedb.writeLog(graceid,message,tagname="analyst_comments")
  print "Response status: %d" % r.status
except HTTPError, e:
  print "Something's wrong: %s" % str(e)
