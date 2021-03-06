// Licensed to the Apache Software Foundation (ASF) under one or more
// contributor license agreements.  See the NOTICE file distributed with
// this work for additional information regarding copyright ownership.
// The ASF licenses this file to You under the Apache License, Version 2.0
// (the "License"); you may not use this file except in compliance with
// the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
var gemfire = require('gemfire');

async function ssl_example() {

    //configure and create client cache
    sslKeyPath="./keys/client/certs"
    console.log('Creating a cache factory')
    cacheFactory = gemfire.createCacheFactory()
    cacheFactory.set("log-file","data/nodeClient.log")
    cacheFactory.set("log-level","config")
    cacheFactory.set("statistic-archive-file","data/clientStatArchive.gfs")

    //Configure keystores and passwords for SSL connections
    cacheFactory.set("ssl-enabled", "true")
    cacheFactory.set('ssl-keystore', sslKeyPath + '/client_keystore.pem')
    cacheFactory.set('ssl-keystore-password', 'apachegeode')
    cacheFactory.set('ssl-truststore', sslKeyPath + '/client_truststore.pem')

    console.log('Create Cache')
    cache = await cacheFactory.create()
    console.log('Create Pool')
    poolFactory = await cache.getPoolManager().createFactory()
    poolFactory.addLocator('localhost', 10337)
    poolFactory.create('pool')

    console.log('Create Region')
    region = await cache.createRegion("test", { type: 'PROXY', poolName: 'pool' })

    try {
      console.log("Do put and get operations")
      console.log('  Putting key \'foo\' with value \'bar\'')
      await region.put('foo', 'bar')

      console.log('  Getting value with key \'foo\'. Expected value: \'bar\'')
      var result = await region.get('foo')
      console.log('  Value retrieved is: \'' + result + '\'')

      console.log('Update operation:')
      console.log('  Updating key \'foo\' with value \'candy\'')
      await region.put('foo', 'candy')
      console.log('  Getting value with key \'foo\'. Expected value: \'candy\'')
      result = await region.get('foo')
      console.log('  Value retrieved is: \'' + result + '\'')

      console.log('Delete operation:')
      console.log('  Removing key \'foo\' from region \'test\'')
      await region.remove('foo')
      console.log('  Getting value with key \'foo\'. Expected value: null')
      result = await region.get('foo')
      console.log('  Value retrieved is: \'' + result + '\'')
    }
    catch (error){
      console.error(error)
    }

    //done with cache then close it
    console.log('Finished')
    cache.close()
    process.exit()
}

ssl_example()
