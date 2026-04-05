const mongoose = require("mongoose");

const User = require("./models/User");
const Client = require("./models/client");
const Product = require("./models/product");
const Company = require("./models/Company");
const Order = require("./models/order");
const OrderTimeline = require("./models/orderTimeline");

const runTest = async () => {
  try {
    await mongoose.connect("mongodb://localhost:27017/BigPharmaDB");
    console.log("--- Starting Backend Tests ---");

    // 1. Setup Test Company
    const testCompany = new Company({ 
      name: "Test Pharmacy Corp",
      email: `test_corp_${Date.now()}@example.com`,
      phone: "0102030405",
      address: "123 Test Street"
    });
    await testCompany.save();
    console.log("1. Test Company created:", testCompany._id);

    // 2. Setup Test User
    const testUser = new User({
      fullName: "Test Admin",
      email: `test_admin_${Date.now()}@example.com`,
      passwordHash: "dummyhash",
      role: "admin",
      companyId: testCompany._id
    });
    await testUser.save();
    console.log("2. Test User created:", testUser._id);

    // 3. Setup Test Client
    const testClient = new Client({
      fullName: "Test Client",
      phone: "0102030405",
      dateOfBirth: new Date(1990, 0, 1),
      gender: "male",
      companyId: testCompany._id
    });
    await testClient.save();
    console.log("3. Test Client created:", testClient._id);

    // 4. Setup Test Product
    const testProduct = new Product({
      name: "Test Aspirin",
      category: "Tablets",
      purchasePrice: 5,
      sellingPrice: 10,
      stockQuantity: 100,
      lots: [{ lotNumber: "LOT-001", quantity: 100, quantityAvailable: 100, costPrice: 5, expirationDate: new Date(2030, 0, 1) }],
      companyId: testCompany._id
    });
    await testProduct.save();
    console.log("4. Test Product created:", testProduct._id, "Stock:", testProduct.stockQuantity);

    // 5. Create Order
    const orderItems = [{
      product: testProduct._id,
      name: testProduct.name,
      price: testProduct.sellingPrice,
      quantity: 10,
      subtotal: 100
    }];

    const orderNumber = `CMD-TEST-${Date.now()}`;
    const order = new Order({
      orderNumber,
      client: testClient._id,
      items: orderItems,
      total: 100,
      createdBy: testUser._id,
      companyId: testCompany._id,
      status: "pending"
    });
    await order.save();
    console.log("5. Order created:", order.orderNumber, "Status:", order.status);

    // 6. Test Status transition (Stock reduction)
    console.log("6. Simulating validation...");
    if (order.status === "pending") {
      order.status = "validated";
      for (const item of order.items) {
        const prod = await Product.findOne({ _id: item.product, companyId: testCompany._id });
        let remainingToDeduct = item.quantity;
        for (const lot of prod.lots) {
          if (lot.quantityAvailable >= remainingToDeduct) {
            lot.quantityAvailable -= remainingToDeduct;
            remainingToDeduct = 0;
            break;
          } else {
            remainingToDeduct -= lot.quantityAvailable;
            lot.quantityAvailable = 0;
          }
        }
        prod.stockQuantity = prod.lots.reduce((sum, l) => sum + (l.quantityAvailable || 0), 0);
        await prod.save();
      }
    }
    await order.save();

    const updatedProduct = await Product.findById(testProduct._id);
    console.log("   Order Status:", order.status);
    console.log("   Stock after validation:", updatedProduct.stockQuantity, "(Expected: 90)");

    if (updatedProduct.stockQuantity === 90) {
      console.log("✅ Stock reduction SUCCESS");
    } else {
      console.log("❌ Stock reduction FAILED");
    }

    // Cleanup
    await Order.deleteOne({ _id: order._id });
    await Product.deleteOne({ _id: testProduct._id });
    await Client.deleteOne({ _id: testClient._id });
    await User.deleteOne({ _id: testUser._id });
    await Company.deleteOne({ _id: testCompany._id });
    console.log("--- Cleanup complete ---");

    await mongoose.disconnect();
    console.log("Test finished.");
  } catch (err) {
    if (err.errors) {
      console.error("VALIDATION ERRORS:", Object.keys(err.errors).map(k => `${k}: ${err.errors[k].message}`));
    }
    console.error("TEST FAILED:", err);
    process.exit(1);
  }
};

runTest();
