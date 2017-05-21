# Copyright 2017 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###############################################################################################
# This file is autogenerated by the repository at https://github.com/gocd/docker-gocd-agent.
# Please file any issues or PRs at https://github.com/gocd/docker-gocd-agent
###############################################################################################

FROM ubuntu:16.04
MAINTAINER GoCD <go-cd-dev@googlegroups.com>

LABEL gocd.version="17.4.0" \
  description="GoCD agent based on ubuntu version 16.04" \
  maintainer="GoCD <go-cd-dev@googlegroups.com>" \
  gocd.full.version="17.4.0-4892" \
  gocd.git.sha="ab17b819e73477a47401744fa64f64fda55c26e8"

ADD "https://download.gocd.io/binaries/17.4.0-4892/generic/go-agent-17.4.0-4892.zip" /tmp/go-agent.zip
ADD "http://mirrors.hust.edu.cn/apache/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.zip" /tmp/apache-maven-3.5.0-bin.zip
ADD tini-static-amd64 /usr/local/sbin/tini
ADD gosu-amd64 /usr/local/sbin/gosu
ADD sources.list /etc/apt/sources.list

# allow mounting ssh keys, dotfiles, and the go server config and data
VOLUME /godata

# force encoding
ENV LANG=en_US.utf8
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
    | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
    | tee -a /etc/apt/sources.list.d/webupd8team-java.list

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

RUN \
# add mode and permissions for files we added above
  chmod 0755 /usr/local/sbin/tini && \
  chown root:root /usr/local/sbin/tini && \
  chmod 0755 /usr/local/sbin/gosu && \
  chown root:root /usr/local/sbin/gosu && \
# add our user and group first to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
  groupadd -g 1000 go && \ 
  useradd -u 1000 -g go -d /home/go -m go && \
  apt-get update && \ 
  apt-get install -y oracle-java8-installer git subversion mercurial openssh-client bash unzip wget && \ 
  apt-get autoclean && \
# unzip the zip file into /go-agent, after stripping the first path prefix
  unzip /tmp/go-agent.zip -d / && \
  mv go-agent-17.4.0 /go-agent && \
  rm /tmp/go-agent.zip && \
  unzip /tmp/apache-maven-3.5.0-bin.zip -d /tmp/ && \
  mv /tmp/apache-maven-3.5.0 /usr/lib/mvn
  
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle
ENV M2_HOME=/usr/lib/mvn
ENV M2=$M2_HOME/bin
ENV PATH=$PATH:$JAVA_HOME/bin:$M2_HOME:$M2

ADD docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
