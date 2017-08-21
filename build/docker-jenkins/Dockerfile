FROM ubuntu:16.04 

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y software-properties-common apt-transport-https wget git curl zip unzip sudo vim ssh-askpass telnet net-tools mysql-client inetutils-ping && rm -rf /var/lib/apt/lists/*

RUN mkdir /root/.ssh/
COPY keys/id_rsa* /root/.ssh/
RUN chmod 0600 /root/.ssh/id_rsa*

#JDK, Gradle and Maven
RUN add-apt-repository ppa:webupd8team/java
RUN add-apt-repository ppa:cwchien/gradle
RUN apt-get update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | \
 debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | \
 debconf-set-selections
RUN add-apt-repository ppa:cwchien/gradle
RUN apt-get install gradle maven build-essential oracle-java8-installer oracle-java8-set-default -y

#Nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g react-native-cli@2.0.1 bower@1.7.9 grunt@1.0.1 typescript@2.1.6 typings@2.1.0

#Android SDK
RUN wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
RUN unzip sdk-tools-linux-3859397.zip -d /opt/android-sdk && rm -f sdk-tools-linux-3859397.zip

RUN apt-get install  lib32gcc1 libc6-i386 lib32z1 lib32stdc++6 lib32ncurses5 lib32gomp1 lib32z1-dev -y

ENV ANDROID_HOME /opt/android-sdk
ENV PATH $ANDROID_HOME/tools/bin:$PATH

RUN echo y | sdkmanager "platforms;android-25"
RUN echo y | sdkmanager "platforms;android-24"
RUN echo y | sdkmanager "platforms;android-23"
RUN echo y | sdkmanager "platform-tools"
RUN echo y | sdkmanager "build-tools;23.0.1"
RUN echo y | sdkmanager "build-tools;23.0.2"
RUN echo y | sdkmanager "build-tools;24.0.0"
RUN echo y | sdkmanager "build-tools;25.0.2"
RUN echo y | sdkmanager "extras;android;m2repository"
RUN echo y | sdkmanager "extras;google;m2repository"

RUN sdkmanager --licenses

#Docker Inside
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
RUN apt-get update
RUN apt-cache policy docker-engine
RUN apt-get install docker-engine ntp -y
RUN curl -L https://github.com/docker/compose/releases/download/1.15.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

#Jenkins
ARG user=jenkins
ARG group=jenkins
ARG uid=1100
ARG gid=1100
ARG http_port=8080
ARG agent_port=50000

ENV JENKINS_HOME /data/jenkins
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container, 
# ensure you use the same uid
RUN groupadd -g ${gid} ${group} \
    && useradd -M -d "$JENKINS_HOME" -u ${uid} -g ${gid} -s /bin/bash ${user}

# Add Jenkins to sudoers without passwd
RUN chmod +w /etc/sudoers; echo "jenkins   ALL=(ALL)       NOPASSWD:ALL" >> /etc/sudoers; chmod -w /etc/sudoers 

# Jenkins home directory is a volume, so configuration and build history 
# can be persisted and survive image upgrades
VOLUME /data/jenkins

# `/usr/share/jenkins/ref/` contains all reference configuration we want 
# to set on a fresh new installation. Use it to bundle additional plugins 
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

ENV TINI_VERSION 0.14.0
ENV TINI_SHA 6c41ec7d33e857d4779f14d9c74924cab0c7973485d2972419a3b7c7620ff5fd

# Use tini as subreaper in Docker container to adopt zombie processes 
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha256sum -c -

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.46.3}

# jenkins.war checksum, download will be validated using it
ARG JENKINS_SHA=00424d3c851298b29376d1d09d7d3578a2bc4a03acf3914b317c47707cd5739a

# Can be used to customize where jenkins.war get downloaded from
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum 
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -

ENV JENKINS_UC https://updates.jenkins.io
RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:
EXPOSE ${http_port}

# will be used by attached slave agents:
EXPOSE ${agent_port}

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
RUN locale-gen $LANG

RUN rm -rf /var/lib/apt/lists/*

USER ${user}

ENV GRADLE_OPTS "-Dorg.gradle.native.dir=/tmp"
RUN gradle -v
RUN java -version

#RUN ssh -o "StrictHostKeyChecking no" user@host

COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY plugins.sh /usr/local/bin/plugins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
