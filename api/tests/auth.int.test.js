const request = require("supertest");
const mongoose = require("mongoose");
const { MongoMemoryServer } = require("mongodb-memory-server-core");

let app;
let mongo;

async function registerAndLogin(overrides = {}) {
  const registerPayload = {
    name: `Pharma ${Date.now()}`,
    email: `company${Date.now()}@example.com`,
    phone: "0102030405",
    address: "Abidjan",
    city: "Abidjan",
    country: "CI",
    fullName: "Admin Test",
    adminEmail: `admin${Date.now()}@example.com`,
    password: "Password123",
    ...overrides,
  };

  const registerRes = await request(app)
    .post("/api/auth/register")
    .send(registerPayload)
    .expect(201);
  const loginRes = await request(app)
    .post("/api/auth/login")
    .send({ email: registerPayload.adminEmail, password: registerPayload.password })
    .expect(200);

  return {
    token: loginRes.body.data.token,
    registerPayload,
    user: loginRes.body.data.user,
  };
}

beforeAll(async () => {
  mongo = await MongoMemoryServer.create();
  process.env.NODE_ENV = "test";
  process.env.JWT_SECRET = "test_secret";
  process.env.MONGODB_URI = mongo.getUri();
  process.env.CORS_ORIGIN = "*";
  process.env.FEATURE_2FA_ENABLED = "false";

  app = require("../app");
});

afterAll(async () => {
  await mongoose.connection.close();
  if (mongo) await mongo.stop();
});

describe("Auth and profile integration", () => {
  it("registers and logs in", async () => {
    const ctx = await registerAndLogin();
    expect(ctx.token).toBeDefined();
  });

  it("does not leak account existence on forgot-password", async () => {
    const existing = await registerAndLogin();

    const known = await request(app)
      .post("/api/auth/forgot-password")
      .send({ email: existing.registerPayload.adminEmail })
      .expect(200);

    const unknown = await request(app)
      .post("/api/auth/forgot-password")
      .send({ email: `unknown${Date.now()}@example.com` })
      .expect(200);

    expect(known.body.message).toEqual(unknown.body.message);
  });

  it("resets password with valid token and rejects reused token", async () => {
    const ctx = await registerAndLogin();

    const forgot = await request(app)
      .post("/api/auth/forgot-password")
      .send({ email: ctx.registerPayload.adminEmail })
      .expect(200);

    const token = forgot.body.data.resetToken;
    expect(token).toBeDefined();

    await request(app)
      .post("/api/auth/reset-password")
      .send({ token, password: "NewPassword123" })
      .expect(200);

    await request(app)
      .post("/api/auth/login")
      .send({ email: ctx.registerPayload.adminEmail, password: "NewPassword123" })
      .expect(200);

    await request(app)
      .post("/api/auth/reset-password")
      .send({ token, password: "AnotherPassword123" })
      .expect(400);
  });

  it("updates current user profile via PUT /api/auth/me", async () => {
    const ctx = await registerAndLogin();

    const res = await request(app)
      .put("/api/auth/me")
      .set("Authorization", `Bearer ${ctx.token}`)
      .send({
        fullName: "Admin Updated",
        email: `updated${Date.now()}@example.com`,
        phoneNumber: "22501020304",
      })
      .expect(200);

    expect(res.body.success).toBe(true);
    expect(res.body.data.fullName).toBe("Admin Updated");
    expect(res.body.data.phone).toBe("22501020304");
  });

  it("enforces admin role for /api/users", async () => {
    const admin = await registerAndLogin();

    const createUser = await request(app)
      .post("/api/users")
      .set("Authorization", `Bearer ${admin.token}`)
      .send({
        fullName: "Assistant One",
        email: `assistant${Date.now()}@example.com`,
        password: "Password123",
        role: "assistant",
      })
      .expect(201);

    expect(createUser.body.success).toBe(true);

    const assistantLogin = await request(app)
      .post("/api/auth/login")
      .send({
        email: createUser.body.data.email,
        password: "Password123",
      })
      .expect(200);

    await request(app)
      .post("/api/users")
      .set("Authorization", `Bearer ${assistantLogin.body.data.token}`)
      .send({
        fullName: "Blocked",
        email: `blocked${Date.now()}@example.com`,
        password: "Password123",
        role: "assistant",
      })
      .expect(403);
  });
});

describe("Mounted routes", () => {
  it("requires auth for protected modules", async () => {
    const protectedRoutes = [
      "/api/sales",
      "/api/finance",
      "/api/activityLogs",
      "/api/QuestionsClients",
      "/api/dashboard/summary",
      "/api/consultations",
      "/api/settings/profile",
    ];

    for (const route of protectedRoutes) {
      const res = await request(app).get(route);
      expect([401, 403]).toContain(res.statusCode);
      expect(res.body.success).toBe(false);
    }
  });

  it("allows authenticated access to finance/activity/consultations aliases", async () => {
    const ctx = await registerAndLogin();

    const financeRes = await request(app)
      .get("/api/finance")
      .set("Authorization", `Bearer ${ctx.token}`)
      .expect(200);
    expect(financeRes.body.success).toBe(true);

    const activityRes = await request(app)
      .get("/api/activityLogs")
      .set("Authorization", `Bearer ${ctx.token}`)
      .expect(200);
    expect(activityRes.body.success).toBe(true);

    const questionsAliasRes = await request(app)
      .get("/api/QuestionsClients")
      .set("Authorization", `Bearer ${ctx.token}`)
      .expect(200);
    expect(questionsAliasRes.body.success).toBe(true);
  });
});
