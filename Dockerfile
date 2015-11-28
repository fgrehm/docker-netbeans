FROM ubuntu:14.04
MAINTAINER Fabio Rehm "fgrehm@gmail.com"

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && apt-get install -y software-properties-common libxext-dev libxrender-dev libxtst-dev fontconfig libfreetype6 wget && \
    add-apt-repository ppa:webupd8team/java -y && \
    add-apt-repository -y ppa:no1wantdthisname/ppa && \
    apt-get update && \
    apt-get install -y fontconfig-infinality fonts-droid && \
    rm /etc/fonts/conf.avail/52-infinality.conf && \
    ln -s /etc/fonts/infinality/infinality.conf /etc/fonts/conf.avail/52-infinality.conf && \
    /etc/fonts/infinality/infctl.sh setstyle win7 && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer libxext-dev libxrender-dev libxtst-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ADD state.xml /tmp/state.xml

RUN wget http://download.netbeans.org/netbeans/8.0.1/final/bundles/netbeans-8.0.1-javase-linux.sh -O /tmp/netbeans.sh -q && \
    chmod +x /tmp/netbeans.sh && \
    echo 'Installing netbeans' && \
    /tmp/netbeans.sh --silent --state /tmp/state.xml && \
    rm -rf /tmp/*

ADD run /usr/local/bin/netbeans

RUN chmod +x /usr/local/bin/netbeans && \
    mkdir -p /home/developer && \
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown developer:developer -R /home/developer

COPY netbeans.conf        /usr/local/netbeans-8.0.1/etc/netbeans.conf
COPY 41-repl-os-win.conf /etc/fonts/infinality/conf.d/41-repl-os-win.conf

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

USER developer

RUN sudo fc-cache -f -v

ENV HOME /home/developer

WORKDIR /home/developer
CMD /usr/local/bin/netbeans
