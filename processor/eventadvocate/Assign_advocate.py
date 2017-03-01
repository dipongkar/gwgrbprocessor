#!/usr/bin/env python
import time, sys, os, commands, subprocess
from string import Template
import numpy as np
from ligo.gracedb.rest import GraceDb, HTTPError
from glue import lal
from pylal import frutils

def sent_advocate_email(send_to,gracedb_id):
    subject = 'GRB advocate: %s' % gracedb_id
    message = """
    Dear recipient, 

    You have been assigned to this event.
    Please go to the GraceDB page:
           https://gracedb.ligo.org/events/%s

    Follow the Event Advocate page for instructions:
           https://wiki.ligo.org/Bursts/GRB:O2EventAdvocates

    Good luck with your shift!
    Thanks,
    The GRB working group
    """ % gracedb_id

    cmd = ['mail', '-s', subject, '-c', 'talukderd@gmail.com', send_to]
    p1 = subprocess.Popen(["echo", message], stdout=subprocess.PIPE)
    p2 = subprocess.Popen(cmd, stdin=p1.stdout, stdout=subprocess.PIPE)
    output = p2.communicate()[0]

def get_advocate_email():
    send_to = ''
    try:
      recipient_list = [line.strip() for line in open('/home/grb.exttrig/Online/O2/processor/eventadvocate/advocate_email_list.txt')]
      recent_list = [line.strip() for line in open('/home/grb.exttrig/Online/O2/processor/eventadvocate/advocate_recent_email.txt')]
      irofile = iter(recipient_list)
      if not recent_list:
         send_to = recipient_list[0]
      else:
         for item in recent_list:
            recent = item
         for line in irofile:
            if(line == recent) and (line == recipient_list[len(recipient_list)-1]):
               send_to = recipient_list[0]
            elif(line == recent):
               send_to = next(irofile)
      with open('/home/grb.exttrig/Online/O2/processor/eventadvocate/advocate_recent_email.txt','w') as f:
         f.write(send_to)
    except Exception, e:
      print(e)
    return send_to

unmatched = ''
grb_list = []
grbdone_list = []
try:
  grb_file = open('/home/grb.exttrig/Online/O2/processor/grbs/grbingracedb_O2.txt','r')
  for lines in grb_file:
      grb_list.append(lines.split()[0])
  grb_list = grb_list[1:]

  grbdoner_file = open('/home/grb.exttrig/Online/O2/processor/eventadvocate/advocate_event_assigned.txt','r')
  for lines in grbdoner_file:
      grbdone_list.append(lines.split()[0])

  unmatched = set(grb_list).symmetric_difference(set(grbdone_list))
  unmatched = list(unmatched)
  print unmatched
except Exception, e:
  print(e)


if not unmatched:
   print "No new event at %s" % time.ctime()
elif len(grb_list) == 0:
   print "GRB list is empty"
elif len(grbdone_list) > len(grb_list):
   print "Assigned event file corrupted"
else:
   for item in unmatched:
     try:
       advemailfile = open('/home/grb.exttrig/Online/O2/processor/eventadvocate/' + item + '_grbemails.txt','a')
       send_to = get_advocate_email()
       advemailfile.write(send_to + '\n')
       advemailfile.write('talukderd@gmail.com' + '\n')
       advemailfile.close()
       sent_advocate_email(send_to,item)
       grbdonea_file = open('/home/grb.exttrig/Online/O2/processor/eventadvocate/advocate_event_assigned.txt','a')
       grbdonea_file.write(item + '\n')
       grbdonea_file.close() 
     except Exception, e:
       print(e)
