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
$APP_HOME = pwd

function build_security_jar() {
    echo ""
    echo "*** Build SimpleSecurityManager ***"
    $env:CLASSPATH="$env:GEODE_HOME\lib\*"
    echo "CLASSPATH=$env:CLASSPATH"
    pushd $APP_HOME/src
      javac securitymanager/SimpleSecurityManager.java
      jar -vcf security.jar *
    popd
}

$GFSH_PATH = ""
if (Get-Command gfsh -ErrorAction SilentlyContinue)
{
    $GFSH_PATH = "gfsh"
}
else
{
    if (-not (Test-Path env:GEODE_HOME))
    {
        Write-Host "Could not find gfsh.  Please set the GEODE_HOME path. e.g. "
        Write-Host "(Powershell) `$env:GEODE_HOME = <path to Geode>"
        Write-Host " OR"
        Write-Host "(Command-line) set %GEODE_HOME% = <path to Geode>"
    }
    else
    {
        $GFSH_PATH = "$env:GEODE_HOME\bin\gfsh.bat"
    }
}

Function launchLocator() {
    echo ""
    echo "*** Start Locator ***"
    mkdir -p $APP_HOME/data/locator
    pushd $APP_HOME/data/locator

    Invoke-Expression "$GFSH_PATH -e 'start locator --name=locator --port=10337 --dir=$APP_HOME/data/locator --connect=false --classpath=$APP_HOME/src/security.jar --J=-Dgemfire.security-manager=securitymanager.SimpleSecurityManager'"
    Invoke-Expression "$GFSH_PATH -e 'connect --locator=localhost[10337] --user=root --password=root-password' -e 'configure pdx --read-serialized=true'"

    popd
}

Function launchServer() {
    echo ""
    echo "*** Start Server ***"
    mkdir -p $APP_HOME/data/server
    pushd $APP_HOME/data/server

    Invoke-Expression "$GFSH_PATH -e 'connect --locator=localhost[10337] --user=root --password=root-password' -e 'start server --user=root --password=root-password --locators=localhost[10337] --server-port=40404 --name=server --dir=$APP_HOME/data/server --classpath=$APP_HOME/src/security.jar --J=-Dgemfire.security-manager=securitymanager.SimpleSecurityManager'"

    popd
}

Function createRegion() {
  echo ""
  echo "*** Create Partition Region \"test\" ***"
  pushd $APP_HOME/data/server

  Invoke-Expression "$GFSH_PATH -e 'connect --locator=localhost[10337] --user=root --password=root-password' -e 'create region --name=test --type=PARTITION'"

  popd
}

echo ""
echo "Geode home =" $env:GEODE_HOME
echo ""
echo "PATH = " $env:PATH
echo ""
echo "Java version:"
java -version

build_security_jar

launchLocator

Start-Sleep -Seconds 10

launchServer

Start-Sleep -Seconds 10

createRegion
