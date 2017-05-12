FROM jkirkby91/docker-java:latest

MAINTAINER James Kirkby <jkirkby91@gmail.com>

RUN groupadd --gid 1000 elasticsearch \
  && useradd --uid 1000 --gid elasticsearch --shell /bin/bash --create-home elasticsearch

ENV PATH=$PATH:/usr/share/elasticsearch/bin

RUN wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    echo 'deb http://packages.elasticsearch.org/elasticsearch/2.x/debian stable main' \
      | tee /etc/apt/sources.list.d/elasticsearch.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y elasticsearch && \
    /usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head && \
    /usr/share/elasticsearch/bin/plugin install --batch lmenezes/elasticsearch-kopf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/elasticsearch/config && \
mkdir /usr/share/elasticsearch/logs && \
touch /usr/share/elasticsearch/logs/elasticsearch.log

#COPY confs/elasticsearch/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

#COPY confs/elasticsearch/logging.yml /usr/share/elasticsearch/config/logging.yml

RUN chown -Rf elasticsearch:elasticsearch /usr/share/elasticsearch

RUN chown -Rf elasticsearch:elasticsearch /srv

COPY confs/supervisord/supervisord.conf /etc/supervisord.conf

COPY confs/apparmor/elasticsearch.conf /etc/apparmor.d/elasticsearch.conf

COPY start.sh /start.sh

RUN chmod 777 /start.sh

RUN chown -Rf elasticsearch:elasticsearch /srv && \
chown -Rf elasticsearch:elasticsearch /usr/share/elasticsearch/  && \
chown -Rf elasticsearch:elasticsearch /etc/elasticsearch

RUN sed -i -e "s%#ES_HOME=/usr/share/elasticsearch%ES_HOME=/usr/share/elasticsearch%g" /etc/default/elasticsearch && \
sed -i -e "s%#CONF_DIR=/etc/elasticsearch%CONF_DIR=/etc/elasticsearch%g" /etc/default/elasticsearch && \
sed -i -e "s%#DATA_DIR=/var/lib/elasticsearch%DATA_DIR=/srv/data%g" /etc/default/elasticsearch && \
sed -i -e "s%#LOG_DIR=/var/log/elasticsearch%LOG_DIR=/var/log/elasticsearch%g" /etc/default/elasticsearch

USER elasticsearch

RUN mkdir /srv/data

RUN chown -Rf elasticsearch:elasticsearch /srv/data

WORKDIR /usr/share/elasticsearch

VOLUME ["/usr/share/elasticsearch/config"]

EXPOSE 9200 9300

CMD ["/bin/bash", "/start.sh"]
