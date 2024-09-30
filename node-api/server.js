const express = require('express');

const redisClient = require('redis'); // Ensure this path is correct

const  client = require('prom-client')

var os = require("os");

const http = require("http");





const app = express();

const PORT = process.env.PORT || 3000;





http.globalAgent.keepAlive = true;



//Redis Connection

const redisclient = redisClient.createClient({ url: 'redis://redis-service:6379' }); 

  

(async () => { 

    await redisclient.connect(); 

})(); 

  

console.log("Connecting to the Redis"); 

  

redisclient.on("ready", () => { 

    console.log("Connected!"); 

}); 

  

redisclient.on("error", (err) => { 

    console.log(err);

    console.log("Error in the Connection"); 

}); 



var hostname = os.hostname();

//prometheus

// Create a Registry which registers the metrics

const register = new client.Registry()



// Add a default label which is added to all metrics

register.setDefaultLabels({

  app: 'sre-challange'

})



// Enable the collection of default metrics

client.collectDefaultMetrics({ register })





const httpRequestDurationMicroseconds = new client.Histogram({

  name: 'http_request_duration_ms',

  help: 'Duration of HTTP requests in ms',

  labelNames: ['method', 'route', 'code'],

  // buckets for response time from 0.1ms to 500ms

  buckets: [0.10, 5, 15, 50, 100, 200, 300, 400, 500]

})





register.registerMetric(httpRequestDurationMicroseconds);







// Runs before each requests

app.use((req, res, next) => {

  res.locals.startEpoch = Date.now()

  next()

})



// Default route

app.get('/', (req, res,next) => {

    try {

        res.status(200).send('Health Ok');

        next()

    } catch (error) {

        console.error('500 status code', error);

        res.status(500).send('Internal Server Error');

    }

});



// Set a value in Redis

app.get('/set', async (req, res,next) => {

    try {

        await redisclient.set('key', 'value');

        res.status(200).send('Value set in Redis');

        next()

    } catch (error) {

        console.error('Error setting value in Redis:', error);

        res.status(500).send('Internal Server Error');

    }

});



// Get a value from Redis

app.get('/get', async (req, res,next) => {

    try {

        const value = await redisclient.get('key');

        res.status(200).send(`Value from Redis: ${value}`);

        next()

    } catch (error) {

        console.error('Error getting value from Redis:', error);

        res.status(500).send('Internal Server Error');

    }

});





// expose our metrics at the default URL for Prometheus

app.get('/metrics', (async (req, res) => {

  res.set('Content-Type', register.contentType);

  res.send(await register.metrics());

}));





// Runs after each requests

app.use((req, res, next) => {

  const responseTimeInMs = Date.now() - res.locals.startEpoch

  httpRequestDurationMicroseconds.labels(req.method, req.originalUrl, res.statusCode).observe(responseTimeInMs)

  next()

})









var server = app.listen(3000);

server.on('connection', function(socket) {

  console.log("A new connection was made by a client.");

  socket.setTimeout(10 * 1000); 

  // 30 second timeout. Change this as you see fit.

});