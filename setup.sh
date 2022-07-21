#!/bin/bash

# basic fancy
echo "╔═══════════════════════════════════════╗"
echo "║ Waffle.Lazy's Minecraft Server Helper ║"
echo "╚═══════════════════════════════════════╝"


# the output folder for the server files that will be used by the docker-compose file
serverFiles="./server-files"
composeFile="./docker-compose-template.yml"
dockerFile="./dockerfile-template"

# make sure needed commands exist
## unzip ##
if ! command -v unzip &> /dev/null; then
    echo "unzip command not found, please install it. Aborting"
    exit
fi

## docker ##
if ! command -v docker &> /dev/null; then
    echo "docker command not found, please install it. Aborting"
    exit
fi

## docker-compose ##
if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose command not found, please install it. Aborting"
    exit
fi

## dos2unix ##
if ! command -v dos2unix &> /dev/null; then
    echo "dos2unix command not found, please install it. Aborting"
    exit
fi

echo "Enter server zip file location"
read serverFilesZip
echo ''

echo "Enter port number to use (25565)"
read port
echo ''

# set default port
if [[ "$port" == "" ]]; then
    port="25565"
fi

echo "Enter container name"
read dockerName
echo ''

echo "Enter required openjdk image tag (8u292-oraclelinux7)"
read openjdkImageTag
echo ''

# set default opdnjdk image tag
if [[ "$openjdkImageTag" == "" ]]; then
    openjdkImageTag="8u292-oraclelinux7"
fi

# remove single quotes from drag/drop into console and trim space
serverFilesZip=$(echo $serverFilesZip | sed "s/'//g" | xargs)

echo "Server files    : $serverFilesZip"
echo "Server Port     : $port"
echo "Container name  : $dockerName"
echo "Container Image : openjdk:$openjdkImageTag"
echo ''
echo "Continue? [y/(n)]"
read startExec

# confirm to continue
if [[ "$startExec" != "y" && "$startExec" != "Y" ]]; then
    echo "aborting"
    exit
fi

# make sure the file exists
if [[ ! -e "$serverFilesZip" ]]; then
    echo "zip not found, aborting"
    exit
fi

# make sure server-files dir doesn't exist
if [[ -e "$serverFiles" ]]; then
    echo "$serverFiles dir exists, aborting"
    exit
fi

# unzip server files to $serverFiles
echo ''
echo "=== Extracting Server Files ==="

unzip "$serverFilesZip" -d "$serverFiles"

if [[ ! -e "$serverFiles/start.sh" ]]; then
    echo "could not find start.sh, aborting"
    echo "removing $serverFiles ..."
    rm -rf $serverFiles
    exit
fi

# update dockerfile to replace <openjdk_tag>
echo ''
echo "=== Upadting docker files ==="
echo -n "  -> $dockerFile: "
sed -i "s/<openjdk_tag>/$openjdkImageTag/" "$dockerFile"

if grep "<openjdk_tag>" "$dockerFile"; then
    echo "Failed to update $dockerFile. Aborting"
    exit
fi

echo "updated"

# update docker-compose to replace <name> with dockerName and <port> with port
echo -n "  -> $composeFile: "
sed -i "s/<name>/$dockerName/g" "$composeFile"
sed -i "s/<port>/$port/g" "$composeFile"

if grep "<name>" $composeFile || grep "<port>" $composeFile; then
    echo "Failed to update $composeFile. Aborting"
    exit
fi

echo "updated"

# add dockerfile to $serverFiles
echo ''
echo "=== Moving Dockerfiles ==="
mv -v "$dockerFile" "$serverFiles/dockerfile"
mv -v "$composeFile" "docker-compose.yml"

# make sure start.sh is executable
chmod +x "$serverFiles/start.sh"

# make sure start.sh has unix line endings
dos2unix "$serverFiles/start.sh"

# run docker build
echo ''
echo "=== Running Docker Build ==="
sudo docker build -t "$dockerName" "$serverFiles"

echo ''
echo "=== Removing Setup ==="
rm -v ./setup.sh

echo ''
echo "=== Done ==="
echo ''
echo "════════════════════════════════════════════════════"
echo "                    Helpful Info                    "
echo "════════════════════════════════════════════════════"
echo " Your server files are located in"
echo " $serverFiles"
echo " You can edit the server.properties, eula.txt, etc" 
echo " as you would normally here"
echo "════════════════════════════════════════════════════"
echo " You can start your server with" 
echo " 'sudo docker-compose up' from within"
echo " $(pwd)"
echo " It is recommended you do this to ensure the server"
echo " starts fully."
echo " Then you can run the server in detached mode with"
echo " 'sudo docker-compose up -d'"
echo "════════════════════════════════════════════════════"
echo " If you just want to view the output of the server"
echo " you can do so with 'sudo docker-compose logs -f'"
echo "════════════════════════════════════════════════════"
echo " You can attach to the container to use commands"
echo " with 'sudo docker attach $dockerName'"
echo "════════════════════════════════════════════════════"
echo " You can detach from the container with"
echo " Ctrl+p followed by Ctrl+q"
echo "════════════════════════════════════════════════════"
