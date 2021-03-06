# The SSL-Put-Get Example

This Node.js example demonstrates basic SSL connection of a client with a GemFire
 Cache cluster. This application leverages the CRUD-ops example, which should
 be reviewed prior starting. The example works with either a local Apache Geode
 or Pivotal GemFire cluster.

# Prerequisites

- **OpenSSL**, Version 1.1.1

- **Node.js**, minimum version of 10.16.3

- **npm**, the Node.js package manager

- **Examples source code**.  Acquire the repository:

    ```
    $ git clone git@github.com:gemfire/node-examples.git
    ```

- **Node.js client library**. Acquire the Node.js client library from PivNet under [Cloud Cache](https://network.pivotal.io/products/p-cloudcache/).
The file is a compressed tar archive (suffix `.tgz`), and the filename contains the client library version number.
For example:
`gemfire-nodejs-client-2.0.0.tgz`.


- **Pivotal GemFire**.
Acquire Pivotal GemFire from PivNet at [Pivotal GemFire](https://network.pivotal.io/products/pivotal-gemfire/). Be sure to install GemFire's prerequisite Java JDK 1.8.X, which is needed to support gfsh, the GemFire command line interface.
Choose your GemFire version based on the version of Cloud Cache in your PAS environment.
See the [Product Snapshot](https://docs.pivotal.io/p-cloud-cache/product-snapshot.html) for your Cloud Cache version.

- **Configure environment variables**.
Set `GEODE_HOME` to the GemFire installation directory and add `$GEODE_HOME/bin` to your `PATH`. For example

    On Mac and Linux:

    ```bash
    export GEODE_HOME=/Users/MyGemFire
    export PATH=$GEODE_HOME/bin:$PATH
    ```

    On Windows (standard command prompt):
  
    ```cmd
    set GEODE_HOME=c:\Users\MyGemFire
    set PATH=%GEODE_HOME%\bin;%PATH%
    ```


# Install GemFire Node.js Client Module

With a current working directory of `node-examples/ssl`,
 install the module:

```bash
$ npm install gemfire-nodejs-client-2.0.0.tgz
$ npm update
```

## Certificates
Certificates for this example are provided under the `node-examples/ssl/keys` directory. For additional details on creating certificates the 
following links may be helpful. 

Certificate generation:
[https://jamielinux.com/docs/openssl-certificate-authority/introduction.html](https://jamielinux.com/docs/openssl-certificate-authority/introduction.html)

JKS keystore import:
[https://blog.codecentric.de/en/2013/01/how-to-use-self-signed-pem-client-certificates-in-java/](https://blog.codecentric.de/en/2013/01/how-to-use-self-signed-pem-client-certificates-in-java/)\


## Start a GemFire Cluster

There are scripts in the `ssl/scripts` directory for creating a GemFire cluster. The `startGemFire` script starts up the simplest cluster of one locator and one cache server. The locator provides administration services for the cluster and a discovery service allowing clients and servers to find each other. The server provides storage for data along with computation services.

The startup script creates a single Region called "test" that the application uses for storing data in the server (similar to a table in relational databases). A region is similar to a hashmap and stores all data as key/value pairs.

The startup script depends on gfsh, the administrative utility provided by the GemFire product.  

With a current working directory of `node-examples/ssl`, run the `startGemFire` script for your system:

On Mac and Linux:

```bash
$ ./scripts/startGemFire.sh
```

On Windows (standard command prompt):

```cmd
$ powershell ./scripts/startGemFire.ps1
```

Logs and other data for the cluster is stored in directory `node-examples/ssl/data`.

Example output:

```bash
$ ./startGemFire.sh
Geode home= /Users/pivotal/Downloads/pivotal-gemfire-9.8.3

PATH = /Users/pivotal/.nvm/versions/node/v10.17.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/VMware Fusion.app/Contents/Public:/usr/local/share/dotnet:~/.dotnet/tools:/Users/pivotal/Downloads/pivotal-gemfire-9.8.3/bin:/usr/local/share/dotnet:/usr/local/opt:/usr/local/opt/nvm:/Users/pivotal/.nvm:/Users/pivotal/Downloads/pivotal-gemfire-9.8.3/bin:/usr/local/share/dotnet 

Java version:
java version "1.8.0_192"
Java(TM) SE Runtime Environment (build 1.8.0_192-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.192-b12, mixed mode)

*** Start Locator ***

(1) Executing - start locator --name=locator --port=10337 --dir=/Users/pivotal/Workspace/node-examples/ssl-put-get/data/locator --connect=false --J=-Dgemfire.ssl-enabled-components=all --J=-Dgemfire.ssl-keystore=/Users/pivotal/Workspace/node-examples/ssl-put-get/keys/server_keystore.p12 --J=-Dgemfire.ssl-truststore=/Users/pivotal/Workspace/node-examples/ssl-put-get/keys/server_truststore.jks --J=-Dgemfire.ssl-keystore-password=apachegeode --J=-Dgemfire.ssl-truststore-password=apachegeode

...
*** Start Server ***
.
Locator in /Users/pivotal/Workspace/node-examples/ssl-put-get/data/locator on 10.118.33.176[10337] as locator is currently online.
Process ID: 69078
Uptime: 7 seconds
Geode Version: 9.8.3
Java Version: 1.8.0_192
Log File: /Users/pivotal/Workspace/node-examples/ssl-put-get/data/locator/locator.log
JVM Arguments: -Dgemfire.enable-cluster-configuration=true -Dgemfire.load-cluster-configuration-from-dir=false -Dgemfire.ssl-enabled-components=all -Dgemfire.ssl-keystore=/Users/pivotal/Workspace/node-examples/ssl-put-get/keys/server_keystore.p12 -Dgemfire.ssl-truststore=/Users/pivotal/Workspace/node-examples/ssl-put-get/keys/server_truststore.jks -Dgemfire.ssl-keystore-password=******** -Dgemfire.ssl-truststore-password=******** -Dgemfire.launcher.registerSignalHandlers=true -Djava.awt.headless=true -Dsun.rmi.dgc.server.gcInterval=9223372036854775806
Class-Path: /Users/pivotal/Downloads/pivotal-gemfire-9.8.3/lib/geode-core-9.8.3.jar:/Users/pivotal/Downloads/pivotal-gemfire-9.8.3/lib/geode-dependencies.jar:/Users/pivotal/Downloads/pivotal-gemfire-9.8.3/extensions/gemfire-greenplum-3.4.1.jar

(1) Executing - connect --locator=localhost[10337] --use-ssl=true --key-store=/Users/pivotal/Workspace/node-examples/ssl-put-get/keys/server_keystore.p12 --trust-store=/Users/pivotal/Workspace/node-examples/ssl-put-get/keys/server_truststore.jks --trust-store-password=***** --key-store-password=*****

Connecting to Locator at [host=localhost, port=10337] ..
Connecting to Manager at [host=10.118.33.176, port=1099] ..
Successfully connected to: [host=10.118.33.176, port=1099]

(2) Executing - start server --locators=localhost[10337] --server-port=40404 --name=server --dir=/Users/pivotal/Workspace/node-examples/ssl-put-get/data/server --J=-Dgemfire.ssl-enabled-components=all --J=-Dgemfire.ssl-keystore=/Users/pivotal/Workspace/node-examples/ssl-put-get/keys/server_keystore.p12 --J=-Dgemfire.ssl-truststore=/Users/pivotal/Workspace/node-examples/ssl-put-get/keys/server_truststore.jks --J=-Dgemfire.ssl-truststore-password=apachegeode --J=-Dgemfire.ssl-keystore-password=apachegeode

...
Server in /Users/pivotal/Workspace/node-examples/ssl-put-get/data/server on 10.118.33.176[40404] as server is currently online.
Process ID: 69201
Uptime: 7 seconds
Geode Version: 9.8.3
Java Version: 1.8.0_192
Log File: /Users/pivotal/Workspace/node-examples/ssl-put-get/data/server/server.log
JVM Arguments: -Dgemfire.locators=localhost[10337] -Dgemfire.start-dev-rest-api=false -Dgemfire.use-cluster-configuration=true -Dgemfire.ssl-enabled-components=all -Dgemfire.ssl-keystore=/Users/pivotal/Workspace/node-examples/ssl-put-get/keys/server_keystore.p12 -Dgemfire.ssl-truststore=/Users/pivotal/Workspace/node-examples/ssl-put-get/keys/server_truststore.jks -Dgemfire.ssl-truststore-password=******** -Dgemfire.ssl-keystore-password=******** -XX:OnOutOfMemoryError=kill -KILL %p -Dgemfire.launcher.registerSignalHandlers=true -Djava.awt.headless=true -Dsun.rmi.dgc.server.gcInterval=9223372036854775806
Class-Path: /Users/pivotal/Downloads/pivotal-gemfire-9.8.3/lib/geode-core-9.8.3.jar:/Users/pivotal/Downloads/pivotal-gemfire-9.8.3/lib/geode-dependencies.jar:/Users/pivotal/Downloads/pivotal-gemfire-9.8.3/extensions/gemfire-greenplum-3.4.1.jar

*** Create Partition Region "test" ***

(1) Executing - connect --locator=localhost[10337] --use-ssl=true --key-store=/Users/pivotal/Workspace/node-examples/ssl-put-get/keys/server_keystore.p12 --trust-store=/Users/pivotal/Workspace/node-examples/ssl-put-get/keys/server_truststore.jks --trust-store-password=***** --key-store-password=*****

Connecting to Locator at [host=localhost, port=10337] ..
Connecting to Manager at [host=10.118.33.176, port=1099] ..
Successfully connected to: [host=10.118.33.176, port=1099]

(2) Executing - create region --name=test --type=PARTITION

Member | Status | Message
------ | ------ | ----------------------------------
server | OK     | Region "/test" created on "server"

Changes to configuration for group 'cluster' are persisted.
```

## Run the Example Application

With a current working directory of `node-examples/ssl`:

On Mac and Linux:

```bash
$ node index.js
```

On Windows (standard command prompt):

```cmd
c:\node-modules\ssl> set PATH=%PATH%;.\node_modules\gemfire\build\Release
c:\node-modules\ssl> node index.js
```

The application demonstrates basic SSL connection of a client with a GemFire Cache cluster.
The application is not interactive.

Example output:

```bash
$ node index.js
Creating a cache factory
Create Cache
Create Pool
Create Region
Do put and get operations
  Putting key 'foo' with value 'bar'
  Getting value with key 'foo'. Expected value: 'bar'
  Value retrieved is: 'bar'
Update operation:
  Updating key 'foo' with value 'candy'
  Getting value with key 'foo'. Expected value: 'candy'
  Value retrieved is: 'candy'
Delete operation:
  Removing key 'foo' from region 'test'
  Getting value with key 'foo'. Expected value: null
  Value retrieved is: 'null'
Finished
```

## Review example code
    
### Configuration

This block of code configures the client cache to use SSL for connecting to . The log location and metrics are written to the data directory. The PoolFactory configures a connection pool which uses the locator to lookup the servers.

There is a small change from the CRUD-ops example configuration. We add the following lines which turn on SSL and configure the location of the keys files and keystores. The keystore requires a password as well which is also configured. 

```javascript
    cacheFactory.set("ssl-enabled", "true")
    cacheFactory.set('ssl-keystore', sslKeyPath + '/client_keystore.pem')
    cacheFactory.set('ssl-keystore-password', 'apachegeode')
    cacheFactory.set('ssl-truststore', sslKeyPath + '/client_truststore.pem')
```

The example should behave in a similar manner to the CRUD example, but with secure connections enabled.

## Clean Up the Local Development Environment

When finished running the example, use the shutdown script to
tear down the GemFire cluster.
With a current working directory of `node-examples/ssl`:

  On Mac and Linux:
  
  ```bash
    $ ./scripts/shutdownGemFire.sh
  ```
  
  On Windows (standard command prompt):
  
  ```cmd
    c:\node-examples\CRUD-ops> powershell ./scripts/shutdownGemFire.ps1
  ```

Use the cleanup script to remove the directories and files containing
GemFire logs created for the cluster.
With a current working directory of `node-examples/ssl`:

  On Mac and Linux:
  
  ```bash
  $ ./scripts/clearGemFireData.sh
  ```

  On Windows (standard command prompt):
    
  ```cmd
  c:\node-examples\CRUD-ops> powershell ./scripts/clearGemFireData.ps1
  ```

