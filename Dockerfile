FROM openjdk:8-jre-alpine
COPY pentaho /home/pentaho
# OpenSSL is necessary for downloads, shadow for creating user accounts
RUN apk add --update openssl shadow && \
#Download and install Pentaho
    wget https://downloads.sourceforge.net/project/pentaho/Data%20Integration/7.1/pdi-ce-7.1.0.0-12.zip \
         -O /tmp/pdi.zip && \
    unzip /tmp/pdi.zip -d /usr/local/lib/ && \
#Download and install MySQL and MariaDB drivers
    wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.44.tar.gz \
         -O /tmp/mysql-connector.tar.gz && \
    tar -C /tmp -zxvf /tmp/mysql-connector.tar.gz && \
    cp /tmp/mysql-connector-java-5.1.44/mysql-connector-java-5.1.44-bin.jar \
       /usr/local/lib/data-integration/lib/ && \
    wget https://downloads.mariadb.com/Connectors/java/connector-java-2.1.2/mariadb-java-client-2.1.2.jar \
         -O  /usr/local/lib/data-integration/lib/mariadb-java-client-2.1.2.jar && \
#Setup pentaho user
    groupadd -r pentaho && useradd --no-log-init -rM -g pentaho pentaho && \
#Give ownership of Pentaho to pentaho user and clean up temp files
    chown -R pentaho:pentaho /usr/local/lib/data-integration && \
    rm -rf /tmp/* && \
    mkdir -p /home/pentaho/data /home/pentaho/repo && \
    chown -R pentaho:pentaho /home/pentaho
#Switch to pentaho user
USER pentaho
#Set default repository settings and Dummy Job
#Make empty directories as mount targets
RUN /usr/local/lib/data-integration/kitchen.sh -rep=Local -job=DummyJob && \
    rm /home/pentaho/repo/DummyJob.kjb
#Set entrypoint to kitchen
ENTRYPOINT ["/usr/local/lib/data-integration/kitchen.sh","-rep=Local"]
