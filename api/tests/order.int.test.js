const request = require("supertest");
const mongoose = require("mongoose");
const { MongoMemoryServer } = require("mongodb-memory-server-core");
const Product = require("../models/product");
const Client = require("../models/client");
const Order = require("../models/order");
const Finance = require("../models/finance");

let app;
let mongo;
let adminToken;
let clientToken;
let adminUser;
let clientUser;
let companyId;

async function setupTestData(testSuffix = Date.now()) {
  // 1. Register Admin and Company
  const adminPayload = {
    name: `Test Pharmacy ${testSuffix}`,
    email: `pharmacy${testSuffix}@test.com`,
    phone: "0102030405",
    address: "Abidjan",
    city: "Abidjan",
    country: "CI",
    fullName: "Pharmacy Admin",
    adminEmail: `admin${testSuffix}@test.com`,
    password: "Password123",
  };

  const adminReg = await request(app).post("/api/auth/register").send(adminPayload).expect(201);
  const adminLogin = await request(app)
    .post("/api/auth/login")
    .send({ email: adminPayload.adminEmail, password: adminPayload.password })
    .expect(200);

  adminToken = adminLogin.body.data.token;
  adminUser = adminLogin.body.data.user;
  companyId = adminLogin.body.data.company.id;

  // 2. Create a product (using Admin token)
  const product = await Product.create({
    name: "Paracetamol",
    category: "Analgesic",
    purchasePrice: 100,
    sellingPrice: 150,
    stockQuantity: 100,
    companyId: companyId,
    lots: [
      {
        lotNumber: "LOT001",
        quantity: 100,
        quantityAvailable: 100,
        costPrice: 100,
        expirationDate: new Date(Date.now() + 1000 * 60 * 60 * 24 * 365),
      },
    ],
  });

  // 3. Register a Client for this company
  const clientPayload = {
    fullName: "John Doe",
    email: `john${testSuffix}@doe.com`,
    phone: `070${String(testSuffix).slice(-7)}`,
    password: "Password123",
    dateOfBirth: "1990-01-01",
    gender: "male",
    address: "Plateau",
    companyId: companyId,
  };

  const clientReg = await request(app)
    .post("/api/auth/register-client")
    .send(clientPayload)
    .expect(201);
  const clientLogin = await request(app)
    .post("/api/auth/login")
    .send({ email: clientPayload.email, password: clientPayload.password })
    .expect(200);

  clientToken = clientLogin.body.data.token;
  clientUser = clientLogin.body.data.user;
  const clientInfo = clientReg.body.data.client;

  return { product, clientInfo };
}

beforeAll(async () => {
  mongo = await MongoMemoryServer.create();
  process.env.NODE_ENV = "test";
  process.env.JWT_SECRET = "test_secret";
  process.env.MONGODB_URI = mongo.getUri();

  app = require("../app");
});

afterAll(async () => {
  await mongoose.connection.close();
  if (mongo) await mongo.stop();
});

describe("Order Integration Flow", () => {
  it("should complete a full order lifecycle: create -> prepare -> validate", async () => {
    const { product, clientInfo } = await setupTestData();

    // 1. Create Order (Client)
    const createRes = await request(app)
      .post("/api/orders")
      .set("Authorization", `Bearer ${clientToken}`)
      .send({
        products: [{ productId: product._id, quantity: 5 }],
        notes: "Test order",
      })
      .expect(201);

    const orderId = createRes.body.data._id;
    expect(createRes.body.data.status).toBe("en_attente");

    // 2. Update to 'en_preparation' (Admin)
    const prepareRes = await request(app)
      .put(`/api/orders/${orderId}/status`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ status: "en_preparation", note: "Preparing items" })
      .expect(200);

    expect(prepareRes.body.data.status).toBe("en_preparation");

    const productAfterPrepare = await Product.findById(product._id);
    expect(productAfterPrepare.stockQuantity).toBe(95);

    // 3. Update to 'validee' (Admin)
    const validateRes = await request(app)
      .put(`/api/orders/${orderId}/status`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ status: "validee", note: "Collected by client" })
      .expect(200);

    expect(validateRes.body.data.status).toBe("validee");

    const finance = await Finance.findOne({ orderId: orderId });
    expect(finance).toBeDefined();
    expect(finance.amount).toBe(750);
  });

  it("should fail to create order if stock is insufficient", async () => {
    const { product } = await setupTestData(Date.now() + 1);

    await request(app)
      .post("/api/orders")
      .set("Authorization", `Bearer ${clientToken}`)
      .send({
        products: [{ productId: product._id, quantity: 200 }],
      })
      .expect(400);
  });
});
