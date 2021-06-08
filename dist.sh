#!/bin/bash

NC="\033[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"

# USER="harm"
# REMOTE_IP="37.97.150.110"
# REMOTE_PATH="/var/www/harmlesskey.com/public_html"
ADDON_NAME="HarmlessQuestRep"
DIST_PATH="dist/"
SRC_PATH="src/"
BRANCH="master"

printf "\n${GREEN}> STARTING DEPLOYMENT${NC}\n"
printf "> Checking out master\n\n"
git checkout ${BRANCH}
if [ $? -ne 0 ]; then
	printf "\n${RED}>> git checkout ${BRANCH} failed${NC}\n"
	exit 1
fi

printf "\n${GREEN}> COPYING FILES${NC}\n"
# mkdir temp
TEMP="${DIST_PATH}${ADDON_NAME}"
# printf ${TEMP}
mkdir ${TEMP}
cp *.lua *.toc ${TEMP}
# zip ${DIST_PATH}${ADDON_NAME}-BC.zip -r ${DIST_PATH}/${ADDON_NAME}
powershell Compress-Archive -Force ${TEMP} ${TEMP}-BC.zip
rm -rf ${TEMP}



# # TODO check for unstaged files
# printf "> Building for production\n"
# npm run build
# if [ $? -ne 0 ]; then
# 	printf "\n${RED}>> npm run build failed${NC}\n"
# 	exit 1
# fi

# printf "\n${YELLOW}> DEPLOYING TO ${REMOTE_IP}${NC}\n"
# scp -r ${LOCAL_PATH} ${USER}@${REMOTE_IP}:${REMOTE_PATH}
# if [ $? -ne 0 ]; then
# 	printf "\n${RED}>> DEPLOY TO SERVER FAILED!${NC}\n"
# 	exit 1
# fi
# printf "\n${GREEN}> DEPLOYED TO SERVER${NC}\n"
