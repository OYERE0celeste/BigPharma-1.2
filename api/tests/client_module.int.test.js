const request = require("supertest");
const mongoose = require("mongoose");

jest.setTimeout(30000);

const Finance = require("../models/finance");
const Invoice = require("../models/invoice");
const Product = require("../models/product");
const Review = require("../models/review");
const Complaint = require("../models/complaint");

let app;
let adminToken;
let clientToken;
let companyId;

async function setupTestData(testSuffix = Date.now()) {
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

  await request(app).post("/api/auth/register").send(adminPayload).expect(201);
  const adminLogin = await request(app)
    .post("/api/auth/login")
    .send({ email: adminPayload.adminEmail, password: adminPayload.password })
    .expect(200);

  adminToken = adminLogin.body.data.token;
  companyId = adminLogin.body.data.company.id;

  const product = await Product.create({
    name: "Paracetamol",
    category: "Analgesic",
    purchasePrice: 100,
    sellingPrice: 150,
    stockQuantity: 100,
    companyId,
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

  const clientPayload = {
    fullName: "John Doe",
    email: `john${testSuffix}@doe.com`,
    phone: `070${String(testSuffix).slice(-7)}`,
    password: "Password123",
    dateOfBirth: "1990-01-01",
    gender: "male",
    address: "Plateau",
    companyId,
  };

  await request(app).post("/api/auth/register-client").send(clientPayload).expect(201);
  const clientLogin = await request(app)
    .post("/api/auth/login")
    .send({ email: clientPayload.email, password: clientPayload.password })
    .expect(200);

  clientToken = clientLogin.body.data.token;

  return { product };
}

beforeAll(async () => {
  process.env.NODE_ENV = "test";
  process.env.JWT_SECRET = "test_secret";
  process.env.MONGODB_URI = mongoose.connection.client.s.url || "mongodb://localhost:27017/test";

  app = require("../app");
});

afterEach(async () => {
  await Promise.all([
    Finance.deleteMany({}),
    Invoice.deleteMany({}),
    Review.deleteMany({}),
    Complaint.deleteMany({}),
    Product.deleteMany({}),
  ]);
});


describe("Client module workflow", () => {
  it("generates an invoice, then allows review and complaint flows", async () => {
    const { product } = await setupTestData();

    const createRes = await request(app)
      .post("/api/orders")
      .set("Authorization", `Bearer ${clientToken}`)
      .send({
        products: [{ productId: product._id, quantity: 2 }],
        notes: "Client workflow test",
        pickupMode: "sur_place",
      })
      .expect(201);

    const orderId = createRes.body.data._id;
    expect(createRes.body.data.invoiceNumber).toBeFalsy();

    await request(app)
      .put(`/api/orders/${orderId}/status`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ status: "en_preparation", note: "Preparing items" })
      .expect(200);

    const invoiceAfterPrepare = await Invoice.findOne({ orderId });
    expect(invoiceAfterPrepare).toBeTruthy();
    expect(invoiceAfterPrepare.paymentStatus).toBe("en_attente");

    const invoiceRes = await request(app)
      .get(`/api/orders/${orderId}/invoice`)
      .set("Authorization", `Bearer ${clientToken}`)
      .expect(200);

    expect(invoiceRes.body.data.invoiceNumber).toBe(invoiceAfterPrepare.invoiceNumber);
    expect(invoiceRes.body.data.pickupMode).toBe("sur_place");

    await request(app)
      .put(`/api/orders/${orderId}/status`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ status: "validee", note: "Collected by client" })
      .expect(200);

    const invoiceAfterValidation = await Invoice.findOne({ orderId });
    expect(invoiceAfterValidation.paymentStatus).toBe("payee");

    const reviewRes = await request(app)
      .post("/api/reviews")
      .set("Authorization", `Bearer ${clientToken}`)
      .send({
        productId: product._id,
        rating: 5,
        comment: "Très satisfait du produit.",
        serviceRating: 4,
        serviceComment: "Bon accompagnement.",
      })
      .expect(201);

    expect(reviewRes.body.data.productName).toBe("Paracetamol");

    const complaintRes = await request(app)
      .post("/api/complaints")
      .set("Authorization", `Bearer ${clientToken}`)
      .send({
        category: "erreur_facture",
        orderId,
        description: "Je souhaite vérifier le détail de la facture.",
      })
      .expect(201);

    expect(complaintRes.body.data.status).toBe("en_attente");
    expect(complaintRes.body.data.orderSnapshot.orderNumber).toBe(
      createRes.body.data.orderNumber
    );
  });

  it("allows admin to create a client without dateOfBirth and gender", async () => {
    const { product } = await setupTestData(Date.now() + 100);

    const createClientRes = await request(app)
      .post("/api/clients")
      .set("Authorization", `Bearer ${adminToken}`)
      .send({
        fullName: "New Walkin Client",
        phone: "0102030409",
      })
      .expect(201);

    expect(createClientRes.body.data.fullName).toBe("New Walkin Client");
    expect(createClientRes.body.data.phone).toBe("0102030409");
    expect(createClientRes.body.data.dateOfBirth).toBeUndefined();
    expect(createClientRes.body.data.gender).toBeUndefined();
  });
});
