# minecraft-server-helper

tl;dr - I'm lazy :)

This is a quick docker/docker-compose setup for running minecraft servers on linux.

# Required Commands, make sure these are installed
- docker
- docker-compose
- unzip
- dos2unix

# Setup
- Get the server files of your liking
- Create a `start.sh` file in your server files with the start command for the server. This will be used by docker to start the container
- Zip up the server files so they extract directly out of the archive, not into a subfolder. (select all files and zip. Don't select to parent folder)
- download this helper tool from releases and extract it. Rename the folder as desired.
- Run `setup.sh` and provide the following when prompted
  - Server zip you created
  - Port the server should use (default is 25565)
  - The docker container name
  - The openjdk image tag to use as the docker base image (default is 8u292-oraclelinux7)
