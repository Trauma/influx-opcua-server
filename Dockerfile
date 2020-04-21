FROM node as build
LABEL autodelete="true"

# Create app directory
WORKDIR /opt/influx-opcua-server

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

# Install dependencies
RUN npm install

# Bundle app source
COPY . .

# Create Binary
RUN npm run build-arm

FROM node

WORKDIR /opt/influx-opcua-server

# Copy React Build Folder
COPY --from=build /opt/influx-opcua-server/example_config/config.json /opt/influx-opcua-server/config.json
COPY --from=build /opt/influx-opcua-server/influx-opcua-server-linux /opt/influx-opcua-server/influx-opcua-server

# Add manager user so we aren't running as root.
RUN useradd -m -b /opt/influx-opcua-server manager \
    && chown -R manager:manager /opt/influx-opcua-server

# Set Privileges
RUN chmod 500 /opt/influx-opcua-server/influx-opcua-server
RUN chmod 400 /opt/influx-opcua-server/config.json

USER manager

# Expose port
EXPOSE 7000

# Command to run the executable
ENTRYPOINT [ "/opt/influx-opcua-server/influx-opcua-server" ]
