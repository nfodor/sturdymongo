#
# MongoDB Dockerfile
#
# https://github.com/dockerfile/mongodb
#

# Pull base image.
#FROM  ubuntu:20.10
FROM  ubuntu:latest
RUN  apt-get update
#RUN  apt-get install -y apt-transport-https
RUN apt-get install -y gnupg
RUN apt-get install -y wget
RUN apt-get install -y curl
RUN wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc |  apt-key add -
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" |  tee /etc/apt/sources.list.d/mongodb-org-5.0.list
RUN  curl https://deb.releases.teleport.dev/teleport-pubkey.asc -o /usr/share/keyrings/teleport-archive-keyring.asc
RUN  echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] https://deb.releases.teleport.dev/ stable main" | tee /etc/apt/sources.list.d/teleport.list > /dev/null

# Update apt-get sources AND install MongoDB
RUN apt-get update && apt-get install -y mongodb-org lsof vim nano teleport
COPY teleport.yaml /etc/teleport/teleport.yaml
COPY docker-entry.sh /docker-entry.sh
COPY init-mongo.js /init-mongo.js
RUN chmod +x /docker-entry.sh
VOLUME /var/lib/teleport /etc/teleport

EXPOSE 3022-3026 3080


# Define mountable directories.
VOLUME ["/data/db"]

# Define working directory.
WORKDIR /data
# Define default command.
ENTRYPOINT ["/docker-entry.sh"]
#ENTRYPOINT ["ls"]

# Expose ports.
#   - 27017: process
#   - 28017: http
EXPOSE 27017
EXPOSE 28017