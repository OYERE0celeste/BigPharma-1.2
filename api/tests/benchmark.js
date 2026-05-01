const autocannon = require('autocannon');

const url = 'http://localhost:5000/api/products';

const instance = autocannon({
  url,
  connections: 10, // default
  pipelining: 1, // default
  duration: 10 // default is 10s
}, (err, result) => {
  if (err) {
    console.error(err);
  } else {
    console.log('Load Test Result:');
    console.log('Requests/sec:', result.requests.average);
    console.log('Latency (ms) - Mean:', result.latency.average);
    console.log('Total Requests:', result.requests.total);
  }
});

autocannon.track(instance, { renderProgressBar: true });
