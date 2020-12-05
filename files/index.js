const aws = require('aws-sdk');
const https = require('https');
const { AWS_REGION } = process.env;
const replicatedRegions = {
  'us-east-1': true,
  'eu-west-1': true,
};

// Define connection details to DynamoDB
// Choose closest regional replica
const documentClient = new aws.DynamoDB.DocumentClient({
  apiVersion: '2012-10-08',
  region: replicatedRegions[AWS_REGION] ? AWS_REGION : 'eu-west-1',
  httpOptions: {
    agent: new https.Agent({
      keepAlive: true,
    }),
  },
});

exports.handler = async (event, context, callback) => {
    let request = event.Records[0].cf.request;
    
    try {  
      // Pull data from DynamoDB
      const data = await documentClient
        .get({
          TableName: 'domainMappings',
          Key: {
            domain: request.headers.host[0].value,
          },
        }).promise();
     
      // Check if target mapping indeed exists
      // If not, target request to error page 
      // (I assume we don't want pass through requests, since service is shared by various clients)
      // Otherwise if request is for /, target 'index.html'
      // Otherwise target request to dedicated page
      if (!(data && data.Item && data.Item.mapping)) {
        request.uri = '/error.html'
      } else if (request.uri == '/') {
        request.uri = '/' + data.Item.mapping + '/index.html';
      } else {
        request.uri = '/' + data.Item.mapping + request.uri;
      }
      
      console.log('Finalizing request with URI: ' + request.uri)

  } catch (e) {
    console.log(e)
  }
  
  callback(null, request);
};
