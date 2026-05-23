/**
 * Migration: Add barcode and qrCode indexes for fast scanning
 * 
 * This migration:
 * 1. Adds unique compound index on {companyId, barcode}
 * 2. Adds unique compound index on {companyId, qrCode}
 * 3. Adds qrCode field to all existing products if missing
 * 4. Verifies no duplicate barcodes within company
 */
module.exports = {
  /**
   * @param db {import('mongodb').Db}
   * @param client {import('mongodb').MongoClient}
   * @returns {Promise<void>}
   */
  async up(db, client) {
    console.log('🔄 Migration: Adding barcode/qrCode indexes and fields...');
    
    const collection = db.collection('products');
    const session = client.startSession();
    
    try {
      await session.withTransaction(async () => {
        // 1. Add qrCode field to all products if missing
        console.log('📝 Adding qrCode field to products...');
        await collection.updateMany(
          { qrCode: { $exists: false } },
          { $set: { qrCode: null } },
          { session }
        );

        // 2. Check for duplicate barcodes within same company
        console.log('🔍 Checking for duplicate barcodes...');
        const duplicates = await collection
          .aggregate([
            { $match: { barcode: { $exists: true, $ne: null, $ne: '' } } },
            { $group: {
              _id: { companyId: '$companyId', barcode: '$barcode' },
              count: { $sum: 1 },
              ids: { $push: '$_id' }
            }},
            { $match: { count: { $gt: 1 } } }
          ], { session })
          .toArray();

        if (duplicates.length > 0) {
          console.warn('⚠️ WARNING: Found duplicate barcodes:');
          duplicates.forEach(dup => {
            console.warn(`   Company: ${dup._id.companyId}, Barcode: ${dup._id.barcode}, Count: ${dup.count}`);
          });
          // NOTE: In production, handle this carefully - maybe keep first, mark others for review
        }

        // 3. Drop existing barcode indexes if they exist (single field)
        console.log('🗑️ Dropping old single-field barcode indexes...');
        try {
          await collection.collection.dropIndex('barcode_1');
        } catch (e) {
          // Index might not exist, that's OK
        }

        // 4. Create new compound unique indexes
        console.log('📍 Creating compound unique indexes...');
        
        // Index for barcode search: {companyId: 1, barcode: 1}
        await collection.createIndex(
          { companyId: 1, barcode: 1 },
          { 
            unique: true,
            sparse: true,  // Allows null/missing values
            background: true,
            name: 'idx_company_barcode_unique'
          }
        );
        console.log('✅ Created index: idx_company_barcode_unique');

        // Index for qrCode search: {companyId: 1, qrCode: 1}
        await collection.createIndex(
          { companyId: 1, qrCode: 1 },
          { 
            unique: true,
            sparse: true,  // Allows null/missing values
            background: true,
            name: 'idx_company_qrcode_unique'
          }
        );
        console.log('✅ Created index: idx_company_qrcode_unique');

        // Additional useful indexes
        await collection.createIndex(
          { companyId: 1, category: 1 },
          { 
            background: true,
            name: 'idx_company_category'
          }
        );
        console.log('✅ Created index: idx_company_category');

        // Index for expiration date queries
        await collection.createIndex(
          { 'lots.expirationDate': 1 },
          { 
            background: true,
            name: 'idx_lots_expiration'
          }
        );
        console.log('✅ Created index: idx_lots_expiration');

        console.log('✨ Migration completed successfully!');
      });
    } catch (error) {
      console.error('❌ Migration failed:', error);
      throw error;
    } finally {
      await session.endSession();
    }
  },

  /**
   * @param db {import('mongodb').Db}
   * @param client {import('mongodb').MongoClient}
   * @returns {Promise<void>}
   */
  async down(db, client) {
    console.log('⏮️ Rollback: Removing barcode/qrCode indexes...');
    
    const collection = db.collection('products');
    const session = client.startSession();
    
    try {
      await session.withTransaction(async () => {
        // Drop the compound indexes
        const indexNames = [
          'idx_company_barcode_unique',
          'idx_company_qrcode_unique',
          'idx_company_category',
          'idx_lots_expiration'
        ];

        for (const indexName of indexNames) {
          try {
            await collection.dropIndex(indexName);
            console.log(`✅ Dropped index: ${indexName}`);
          } catch (e) {
            console.warn(`⚠️ Index ${indexName} not found, skipping...`);
          }
        }

        // Remove qrCode field (optional - comment out to keep field)
        // await collection.updateMany(
        //   { qrCode: { $exists: true } },
        //   { $unset: { qrCode: '' } },
        //   { session }
        // );
        // console.log('✅ Removed qrCode field');

        console.log('✨ Rollback completed successfully!');
      });
    } catch (error) {
      console.error('❌ Rollback failed:', error);
      throw error;
    } finally {
      await session.endSession();
    }
  }
};
