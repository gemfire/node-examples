#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

APP_HOME="`pwd -P`"

function build_security_jar() {
  echo ""
  echo "*** Build SimpleSecurityManager ***"
  export CLASSPATH=$GEODE_HOME/lib/*
  echo "CLASSPATH=${CLASSPATH}"
  pushd ${APP_HOME}/src > /dev/null
    javac securitymanager/SimpleSecurityManager.java
    jar -vcf security.jar *
  popd > /dev/null
}

function launchLocator() {
    echo ""
    echo "*** Start Locator ***"
    mkdir -p ${APP_HOME}/data/locator
    pushd ${APP_HOME}/data/locator > /dev/null

      gfsh -e "start locator --connect=false --name=locator --bind-address=127.0.0.1 --port=10337 --dir=${APP_HOME}/data/locator --classpath=${APP_HOME}/src/security.jar --J=-Dgemfire.security-manager=securitymanager.SimpleSecurityManager"
      gfsh -e "connect --locator=localhost[10337] --user=root --password=root-password" -e "configure pdx --read-serialized=true"

    popd > /dev/null
}

function launchServer() {
    echo ""
    echo "*** Start Server ***"
    mkdir -p ${APP_HOME}/data/server
    pushd ${APP_HOME}/data/server > /dev/null

      gfsh -e "connect --locator=localhost[10337] --user=root --password=root-password" -e "start server --user=root --password=root-password --bind-address=127.0.0.1 --locators=localhost[10337] --server-port=40404 --name=server --dir=${APP_HOME}/data/server  --classpath=${APP_HOME}/src/security.jar --J=-Dgemfire.security-manager=securitymanager.SimpleSecurityManager"

    popd > /dev/null
}

function createRegion(){
  echo ""
  echo "*** Create Partition Region \"test\" ***"
  pushd ${APP_HOME}/data/server > /dev/null

  gfsh -e "connect --locator=localhost[10337] --user=root --password=root-password " -e "create region --name=test --type=PARTITION"

  popd > /dev/null
}

echo ""
echo "Geode home= ${GEODE_HOME}"
echo ""
echo "PATH = ${PATH} "
echo ""
echo "Java version:"
java -version

build_security_jar

launchLocator

sleep 10

launchServer

sleep 10

createRegion
