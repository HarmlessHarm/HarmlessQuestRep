#!/bin/bash

NC="\033[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"

# USER="harm"
# REMOTE_IP="37.97.150.110"
# REMOTE_PATH="/var/www/harmlesskey.com/public_html"
ADDON_NAME="HarmlessQuestRep"
BCC_FLAG="-BCC"
ERA_FLAG="-ERA"
DIST_PATH="dist/"
BRANCH="master"

printf "\n${GREEN}> STARTING DEPLOYMENT${NC}\n"
printf "> Checking out master\n\n"
git checkout ${BRANCH}
if [ $? -ne 0 ]; then
	printf "\n${RED}>> git checkout ${BRANCH} failed${NC}\n"
	exit 1
fi

printf "\n${GREEN}> COPYING FILES${NC}\n"
TEMP="${DIST_PATH}${ADDON_NAME}"
mkdir ${TEMP}
cp *.lua *.toc ${TEMP}

printf "\n${GREEN}> CREATING ERA DIST${NC}\n"
cp ${TEMP}/${ADDON_NAME}${ERA_FLAG}.toc ${TEMP}/${ADDON_NAME}.toc
powershell Compress-Archive -Force ${TEMP} ${TEMP}${ERA_FLAG}.zip

printf "\n${GREEN}> CREATING BCC DIST${NC}\n"
cp ${TEMP}/${ADDON_NAME}${BCC_FLAG}.toc ${TEMP}/${ADDON_NAME}.toc
powershell Compress-Archive -Force ${TEMP} ${TEMP}${BCC_FLAG}.zip

printf "\n${GREEN}> CLEANING UP${NC}\n"
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
