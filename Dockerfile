FROM python:3.11-bullseye

RUN set -ex && apt update && apt install -y --no-install-recommends openjdk-17-jdk curl unzip rsync build-essential software-properties-common
RUN apt clean && rm -rf /var/lib/apt/lists/*

ENV SPARK_HOME="/opt/spark"
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
ENV PATH="${JAVA_HOME}:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}"
RUN mkdir -p ${SPARK_HOME}
WORKDIR ${SPARK_HOME}
# Fetch latest spark 3.5.x version and download the appropriate binary file
RUN curl -4 -L --url "https://dlcdn.apache.org/spark/spark-4.0.1/spark-4.0.1-bin-hadoop3-connect.tgz" -O

# Unpack the file and cleanup the binary file
RUN tar xvzf spark-4.0.1-bin-hadoop3-connect.tgz --directory ${SPARK_HOME} --strip-components 1 \
    && rm -rf spark-4.0.1-bin-hadoop3-connect.tgz

# Port master will be exposed
ENV SPARK_MASTER_PORT="7077"
# Name of master container and also counts as hostname
ENV SPARK_MASTER_HOST="spark-master"

COPY spark-defaults.conf "/opt/spark/conf"
ENTRYPOINT ["/bin/bash"]
