FROM alpine:3.10 as build
LABEL autodelete="true"

# Create app directory
WORKDIR /opt/influx-opcua-server

# Install dependencies
RUN apk update && apk upgrade && apk add --no-cache \
  nodejs \
  npm \
  openssl \
  bash \ 
  musl-dev \
  python \
  make

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

# Install dependencies
RUN npm install

# Bundle app source
COPY . .

# Create Binary
RUN npm run build-alpine

FROM alpine:3.10

# Install dependencies
RUN apk update && apk upgrade && apk add --no-cache \
  nodejs

WORKDIR /opt/influx-opcua-server

# Copy React Build Folder
COPY --from=build /opt/influx-opcua-server/example_config/config.json /opt/influx-opcua-server/config.json
COPY --from=build /opt/influx-opcua-server/influx-opcua-server-alpine /opt/influx-opcua-server/influx-opcua-server

# Add manager user so we aren't running as root.
RUN adduser -h /opt/influx-opcua-server -D -H manager \
    && chown -R manager:manager /opt/influx-opcua-server

# Set Privileges
RUN chmod 500 /opt/influx-opcua-server/influx-opcua-server
RUN chmod 400 /opt/influx-opcua-server/config.json

USER manager

# Expose port
EXPOSE 7000

# Command to run the executable
ENTRYPOINT [ "/opt/influx-opcua-server/influx-opcua-server" ]
