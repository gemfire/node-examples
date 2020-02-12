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

Write-Debug "GFSH_PATH == $GFSH_PATH"
if ($GFSH_PATH -ne "")
{
   Write-Debug "$GFSH_PATH -e 'start locator --name=locator --port=10337 --dir=$PSScriptRoot\locator'"
   Invoke-Expression "$GFSH_PATH -e 'start locator --name=locator --port=10337 --dir=$PSScriptRoot\locator'"
   Write-Debug "$GFSH_PATH -e 'connect --locator=localhost[10337]' -e 'start server --name=server --dir=$PSScriptRoot\server'" 
   Invoke-Expression "$GFSH_PATH -e 'connect --locator=localhost[10337]' -e 'start server --name=server --dir=$PSScriptRoot\server'" 
   Write-Debug "$GFSH_PATH -e 'connect --locator=localhost[10337]' -e 'create region --name=test --type=PARTITION'"
   Invoke-Expression "$GFSH_PATH -e 'connect --locator=localhost[10337]' -e 'create region --name=test --type=PARTITION'"
}