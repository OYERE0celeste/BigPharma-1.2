const mongoose = require("mongoose");

let Company;
let User;
let seedAdmin;

beforeAll(async () => {
  process.env.NODE_ENV = "test";
  process.env.JWT_SECRET = "test_secret";
  process.env.MONGODB_URI = mongoose.connection.client.s.url || "mongodb://localhost:27017/test";

  Company = require("../models/Company");
  User = require("../models/User");
  ({ seedAdmin } = require("../utils/seeder"));

  await mongoose.connect(process.env.MONGODB_URI);
});

afterEach(async () => {
  await Promise.all([Company.deleteMany({}), User.deleteMany({})]);
});


describe("Default admin seeding", () => {
  it("creates the default company and admin when no admin exists", async () => {
    await seedAdmin();

    const company = await Company.findOne({ email: "contact@bigpharma.com" });
    const admins = await User.find({ role: "administrateur" });

    expect(company).toBeTruthy();
    expect(admins).toHaveLength(1);
    expect(admins[0].email).toBe("laflorale8@gmail.com");
    expect(admins[0].companyId.toString()).toBe(company._id.toString());
  });

  it("does not recreate the seeded email after an admin changes email", async () => {
    await seedAdmin();

    const admin = await User.findOne({ role: "administrateur" });
    admin.email = "laflorales@gmail.com";
    await admin.save();

    await seedAdmin();

    const admins = await User.find({ role: "administrateur" }).sort({ createdAt: 1 });

    expect(admins).toHaveLength(1);
    expect(admins[0].email).toBe("laflorales@gmail.com");
  });
});
