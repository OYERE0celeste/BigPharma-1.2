require("dotenv").config();

const app = require("./app");
// Force reload for new transitions

const { initCronJobs } = require("./utils/cronJobs");

const PORT = Number(process.env.PORT || 5000);

initCronJobs();

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
