const promClient = require("prom-client");

// Create a Registry which can register metrics
const register = new promClient.Registry();

// Add a default label which is added to all metrics
register.setDefaultLabels({
  app: "bigpharma-api"
});

// Enable the collection of default metrics
promClient.collectDefaultMetrics({ register });

// Create a custom histogram for HTTP request duration
const httpRequestDurationMicroseconds = new promClient.Histogram({
  name: "http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

// Register the custom metric
register.registerMetric(httpRequestDurationMicroseconds);

const metricsMiddleware = (req, res, next) => {
  const start = process.hrtime();

  res.on("finish", () => {
    const elapsed = process.hrtime(start);
    const durationInSeconds = elapsed[0] + elapsed[1] / 1e9;
    
    const route = req.route ? req.route.path : req.path;
    
    httpRequestDurationMicroseconds.labels(req.method, route, res.statusCode).observe(durationInSeconds);
  });

  next();
};

module.exports = {
  metricsMiddleware,
  register
};
