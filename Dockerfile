FROM openjdk:8-jre-alpine
# OpenSSL is necessary for downloads, shadow for creating user accounts
RUN apk add --update openssl shadow
#Download and install Pentaho
RUN wget https://downloads.sourceforge.net/project/pentaho/Data%20Integration/7.1/pdi-ce-7.1.0.0-12.zip \
         -O /tmp/pdi.zip && \
    unzip /tmp/pdi.zip -d /usr/local/lib/
#Download and install MySQL and MariaDB drivers
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.44.tar.gz \
         -O /tmp/mysql-connector.tar.gz && \
    tar -C /tmp -zxvf /tmp/mysql-connector.tar.gz && \
    cp /tmp/mysql-connector-java-5.1.44/mysql-connector-java-5.1.44-bin.jar \
       /usr/local/lib/data-integration/lib/
RUN wget https://downloads.mariadb.com/Connectors/java/connector-java-2.1.2/mariadb-java-client-2.1.2.jar \
         -O  /usr/local/lib/data-integration/lib/mariadb-java-client-2.1.2.jar
#Setup pentaho user
RUN groupadd -r pentaho && useradd --no-log-init -rm -g pentaho pentaho
WORKDIR /home/pentaho
#Give ownership of Pentaho to pentaho user and clean up temp files
RUN chown -R pentaho:pentaho /usr/local/lib/data-integration && rm -rf /tmp/*
#Switch to pentaho user
USER pentaho
#Set default repository settings
COPY .kettle .kettle
#Make empty directories as mount targets
RUN mkdir data repo
#Run a dummy job so the configuration files are generated
COPY DummyJob.kjb repo/DummyJob.kjb
RUN /usr/local/lib/data-integration/kitchen.sh -rep=Local -job=DummyJob && rm repo/DummyJob.kjb
#Set entrypoint to kitchen
ENTRYPOINT ["/usr/local/lib/data-integration/kitchen.sh","-level=Minimal","-rep=Local"]
