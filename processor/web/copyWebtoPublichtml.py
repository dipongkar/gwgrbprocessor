import os
import shutil

web = os.stat('OnlineGRB_page_preER7.html')
file_size = web.st_size

if file_size > 10:
    shutil.copy2('/home/grb.exttrig/Online/preER7/processor/web/OnlineGRB_page_preER7.html','/home/grb.exttrig/public_html/web/preER7/OnlineGRB_page_preER7.html')
    print "Done"
else:
    print "File is empty"


