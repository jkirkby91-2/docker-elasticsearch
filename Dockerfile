FROM jkirkby91/docker-java:latest

MAINTAINER James Kirkby <jkirkby91@gmail.com>

ENV PATH=$PATH:/usr/share/elasticsearch/bin

RUN wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    echo 'deb http://packages.elasticsearch.org/elasticsearch/2.x/debian stable main' \
      | tee /etc/apt/sources.list.d/elasticsearch.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y elasticsearch && \
    /usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/share/elasticsearch

RUN set -ex \
  && for path in \
  ./data \
    ./logs \
    ./config \
    ./config/scripts \
  ; do \
    mkdir -p "$path"; \
    chown -R elasticsearch:elasticsearch "$path"; \
  done

COPY confs/elasticsearch/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

COPY confs/elasticsearch/logging.yml /usr/share/elasticsearch/config/logging.yml

# Copy supervisor conf
COPY confs/supervisord/supervisord.conf /etc/supervisord.conf

COPY start.sh /start.sh

RUN chmod 777 /start.sh

USER elasticsearch

VOLUME ["/usr/share/elasticsearch"]

EXPOSE 9200 9300

# Set entrypoint
CMD ["/bin/bash", "/start.sh"]
