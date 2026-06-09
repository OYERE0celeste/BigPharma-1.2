module.exports = {
  /**
   * @param db {import('mongodb').Db}
   * @param client {import('mongodb').MongoClient}
   * @returns {Promise<void>}
   */
  async up(db, client) {
    await db.collection('users').createIndex({ email: 1 }, { unique: true });
    await db.collection('products').createIndex({ companyId: 1, name: 1 });
    await db.collection('products').createIndex({ barcode: 1 });
    await db.collection('orders').createIndex({ companyId: 1, orderNumber: 1 });
    await db.collection('orders').createIndex({ status: 1 });
    await db.collection('clients').createIndex({ companyId: 1, email: 1 });
    await db.collection('clients').createIndex({ companyId: 1, phone: 1 });
  },

  async down(db, client) {
    await db.collection('users').dropIndex("email_1");
    await db.collection('products').dropIndex("companyId_1_name_1");
    await db.collection('products').dropIndex("barcode_1");
    await db.collection('orders').dropIndex("companyId_1_orderNumber_1");
    await db.collection('orders').dropIndex("status_1");
    await db.collection('clients').dropIndex("companyId_1_email_1");
    await db.collection('clients').dropIndex("companyId_1_phone_1");
  }
};
