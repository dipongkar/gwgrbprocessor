The basic design for online GRB processor can be found in design.pdf in processor directory.

** One must have a robotic certificate or periodically updated LIGO credentials to automatically run either X-pipeline or CBC-GRB (known as cohPTF) or both for the GRB searches using this processor.

** One must have X-pipeline or CBC-GRB codes installed and sourced in profile.

Setup instructions:

After checking out the repository,

1) Go to processor directory, edit make_dir.sh to change RUN name (see below), example preER7 may be changed to ER7 or whatever. Execute make_dir.sh. This will setup couple of directories needed. The processor will be running under $HOME/Online/RUN/processor/. Put your email(s) in grbemails.txt to receive notifications.

2) Go to $HOME/Online/RUN/processor directory
   
   Edit exttrig_params.pl to change $LIGORUN, $LIGORUN_START_TIME, $LIGORUN_END_TIME, and $PUBSERVER if needed. Other parameters may need change depending of when and where the processor is running.
  
   2a) Go to params/CBC/ and edit ADE_GRB_post_processing.ini and ADE_GRB_trigger_hipe.ini to  	 
       point your executable in [condor] section. Edit other files as needed appropriate for the
       run.
     
   2b) Go to params/X/ and edit grb_online.ini to point lag file and your log-files path in
       [background] and [condor] sections. Modify parameters as needed.  

3) In $HOME/RUN/processor initiate the whole process by running a few scripts

   3a) nohup ./queryGraceDB > nohup_queryGraceDB_out.txt&
   3b) nohup ./CBCprocessGRB > nohup_CBCprocessGRB_out.txt&     (ignore it if you are running only X-pipeline)  
   3c) nohup ./XprocessGRB > nohup_XprocessGRB_out.txt&         (ignore it if you are running only CBC-GRB)
   3d) nohup ./monitorJobs > nohup_monitorJobs_out.txt&

4) In $HOME/RUN/processor/web/, run
   nohup ./copyWeb > nohup_copyWeb_out.txt&


