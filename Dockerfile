FROM shoothzj/base

ARG TARGETARCH

RUN apt-get update && \
    # for doris
    apt-get install -y binutils xz-utils && \
    apt-get install -y --no-install-recommends openjdk-8-jdk unzip && \
    apt-get install -y mysql-client && \
    apt-get -y --purge autoremove && \
    apt-get autoclean && \
    apt-get clean && \
    wget https://github.com/alibaba/arthas/releases/download/arthas-all-3.6.7/arthas-bin.zip && \
    mkdir -p /usr/local/lib/arthas && \
    unzip arthas-bin.zip -d /usr/local/lib/arthas && \
    rm -rf arthas-bin.zip && \
    echo "alias arthas='java -jar /usr/local/lib/arthas/arthas-boot.jar'" >> /root/.bashrc

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-$TARGETARCH

WORKDIR /opt

ARG amd_download=1.2.2-bin-x86_64
ARG arm_download=1.2.2-bin-arm

RUN if [ "$TARGETARCH" = "amd64" ]; \
    then download=$amd_download; \
    else download=$arm_download; \
    fi && \
    wget -q https://archive.apache.org/dist/doris/1.2/1.2.2-rc01/apache-doris-be-$download.tar.xz && \
    wget -q https://archive.apache.org/dist/doris/1.2/1.2.2-rc01/apache-doris-fe-$download.tar.xz && \
    wget -q https://archive.apache.org/dist/doris/1.2/1.2.2-rc01/apache-doris-dependencies-$download.tar.xz && \
    mkdir -p /opt/doris/be && \
    mkdir -p /opt/doris/fe && \
    mkdir -p /opt/doris/dep && \
    tar -xf apache-doris-be-$download.tar.xz -C /opt/doris/be --strip-components 1 && \
    tar -xf apache-doris-fe-$download.tar.xz -C /opt/doris/fe --strip-components 1 && \
    tar -xf apache-doris-dependencies-$download.tar.xz -C /opt/doris/dep --strip-components 1 && \
    strip /opt/doris/be/lib/doris_be && \
    mv /opt/doris/dep/java-udf-jar-with-dependencies.jar /opt/doris/be/lib/ && \
    rm -rf /opt/apache-doris-be-$download.tar.xz && \
    rm -rf /opt/apache-doris-fe-$download.tar.xz && \
    rm -rf /opt/apache-doris-dependencies-$download.tar.xz

WORKDIR /opt/doris
