# Pull base image.
FROM sebp/elk:latest

ADD ./03-tcp-input.conf /etc/logstash/conf.d/03-tcp-input.conf
ADD ./30-output.conf /etc/logstash/conf.d/30-output.conf

WORKDIR ${KIBANA_HOME}
RUN gosu kibana bin/kibana-plugin install https://github.com/sivasamyk/logtrail/releases/download/v0.1.19/logtrail-5.5.1-0.1.19.zip
COPY ./logtrail.json /opt/kibana/plugins/logtrail/logtrail.json

#Install X-PAC
RUN /opt/elasticsearch/bin/elasticsearch-plugin install x-pack
RUN /opt/kibana/bin/kibana-plugin install x-pack
RUN whereis logstash-plugin
RUN /opt/logstash/bin/logstash-plugin install x-pack
EXPOSE 4560
