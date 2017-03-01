#!/bin/sh

RUN=O2


PWD=$(pwd)
PROCESS_DIR=${HOME}/Online/${RUN}/processor/
mkdir -p $PROCESS_DIR
cp -r ${PWD}/* ${PROCESS_DIR}/

NOTES_DIR=${HOME}/public_html/grb/online/${RUN}/search/notes
mkdir -p $NOTES_DIR
RESULTS_DIR=${HOME}/public_html/grb/online/${RUN}/search/results
mkdir -p $RESULTS_DIR
WEB_DIR=${HOME}/public_html/web/${RUN}
mkdir -p $WEB_DIR

cp -r ${HOME}/Online/${RUN}/processor/web/grbnotes_template.html ${NOTES_DIR}/
cp -r ${HOME}/Online/${RUN}/processor/web/OnlineGRB_page_template.html ${HOME}/Online/${RUN}/processor/web/OnlineGRB_page_${RUN}.html

cd $PROCESS_DIR

sed -i.tmp -e "s|require 'exttrig_params.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_params.pl';|g" -e "s|require 'exttrig_utils.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_utils.pl';|g" XprocessGRB
sed -i.tmp -e "s|require 'exttrig_params.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_params.pl';|g" -e "s|require 'exttrig_utils.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_utils.pl';|g" XmonitorGRB
sed -i.tmp -e "s|require 'exttrig_params.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_params.pl';|g" -e "s|require 'exttrig_utils.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_utils.pl';|g" XmonitorPostproc
sed -i.tmp -e "s|require 'exttrig_params.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_params.pl';|g" -e "s|require 'exttrig_utils.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_utils.pl';|g" XmonitorOpenbox
sed -i.tmp -e "s|require 'exttrig_params.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_params.pl';|g" -e "s|require 'exttrig_utils.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_utils.pl';|g" CBCprocessGRB
sed -i.tmp -e "s|require 'exttrig_params.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_params.pl';|g" -e "s|require 'exttrig_utils.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_utils.pl';|g" CBCmonitorGRB
sed -i.tmp -e "s|require 'exttrig_params.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_params.pl';|g" -e "s|require 'exttrig_utils.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_utils.pl';|g" CBCmonitorPostproc
sed -i.tmp -e "s|require 'exttrig_params.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_params.pl';|g" -e "s|require 'exttrig_utils.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_utils.pl';|g" CBCmonitorOpenbox

sed -i.tmp "s|require 'exttrig_params.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_params.pl';|g" queryGraceDB
sed -i.tmp "s|require 'exttrig_params.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_params.pl';|g" monitorJobs
sed -i.tmp "s|require 'exttrig_params.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_params.pl';|g" copyWeb
sed -i.tmp "s|require 'exttrig_params.pl';|require '${HOME}/Online/${RUN}/processor/exttrig_params.pl';|g" getupdatedparam.pl

rm -r XprocessGRB.tmp XmonitorGRB.tmp XmonitorPostproc.tmp XmonitorOpenbox.tmp CBCprocessGRB.tmp CBCmonitorGRB.tmp CBCmonitorPostproc.tmp CBCmonitorOpenbox.tmp queryGraceDB.tmp monitorJobs.tmp copyWeb.tmp getupdatedparam.pl.tmp

