#!/bin/sh

RUN=preER7

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
