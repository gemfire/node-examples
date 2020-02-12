$APP_HOME = pwd

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

    Invoke-Expression "$GFSH_PATH -e 'start locator --name=locator --port=10337 --dir=$APP_HOME/data/locator --connect=false'"
    Invoke-Expression "$GFSH_PATH -e 'connect --locator=localhost[10337]' -e 'configure pdx --read-serialized=true'"

    popd
}

Function launchServer() {
    echo ""
    echo "*** Start Server ***"
    mkdir -p $APP_HOME/data/server
    pushd $APP_HOME/data/server

    Invoke-Expression "$GFSH_PATH -e 'connect --locator=localhost[10337] ' -e 'start server --locators=localhost[10337] --server-port=40404 --name=server --dir=$APP_HOME/data/server'"

    popd
}

Function createRegion() {
  echo ""
  echo "*** Create Partition Region \"test\" ***"
  pushd $APP_HOME/data/server

  Invoke-Expression "$GFSH_PATH -e 'connect --locator=localhost[10337]' -e 'create region --name=test --type=PARTITION'"

  popd
}

function buildFunction() {
    echo ""
    echo "*** Build Function Jar ***"
    $env:CLASSPATH="$env:GEODE_HOME\lib\*"

    pushd $APP_HOME/src 
      echo "GEODE_HOME=$env:GEODE_HOME"
      echo "CLASSPATH=$env:CLASSPATH"
      javac com/vmware/example/SumRegion.java
      jar -cvf SumRegion.jar *
    popd
}

function deployFunction() {
    echo ""
    echo "*** Deploy Function Jar ***"
    Invoke-Expression "$GFSH_PATH -e 'connect --locator=localhost[10337]' -e 'deploy --jar=$APP_HOME/src/SumRegion.jar'"
}

echo ""
echo "Geode home =" $env:GEODE_HOME
echo ""
echo "PATH = " $env:PATH
echo ""
echo "Java version:"
java -version

buildFunction

launchLocator

Start-Sleep -Seconds 10

launchServer

Start-Sleep -Seconds 10

createRegion

deployFunction