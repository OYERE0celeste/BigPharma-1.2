const mongoose = require("mongoose");
require("dotenv").config();

async function archiveOldData() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("Connected to MongoDB for archiving...");

    const sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

    const ActivityLog = mongoose.connection.collection("activitylogs");
    const ArchiveCollection = mongoose.connection.collection("activitylogs_archive");

    console.log(`Searching for logs older than ${sixMonthsAgo.toISOString()}...`);

    const oldLogs = await ActivityLog.find({ createdAt: { $lt: sixMonthsAgo } }).toArray();

    if (oldLogs.length > 0) {
      console.log(`Archiving ${oldLogs.length} records...`);
      await ArchiveCollection.insertMany(oldLogs);
      
      const ids = oldLogs.map(log => log._id);
      await ActivityLog.deleteMany({ _id: { $in: ids } });
      
      console.log("Archiving successful.");
    } else {
      console.log("No records to archive.");
    }

    await mongoose.disconnect();
  } catch (err) {
    console.error("Archiving failed", err);
    process.exit(1);
  }
}

archiveOldData();
