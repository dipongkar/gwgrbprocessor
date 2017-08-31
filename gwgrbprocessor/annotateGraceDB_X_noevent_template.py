from ligo.gracedb.rest import GraceDb, HTTPError

gracedb = GraceDb()
graceid = 'EVENT_ID'
message = 'Online X-pipeline: No significant event in on-source \
          (FAP = PROBABILITY_VAL for the most significant event). For full \
          results, see \
          <a href="PUBSERVER/~USERNAME/grb/online/LIGORUN/search/results/EVENT_ID_online/EVENT_ID_online_openbox.shtml">here</a>.'
try:
    r = gracedb.writeLog(graceid, message, tagname="ext_coinc")
    print "Response status: %d" % r.status
except HTTPError, e:
    print "Something's wrong: %s" % str(e)
