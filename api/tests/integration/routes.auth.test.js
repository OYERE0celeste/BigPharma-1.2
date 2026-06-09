const request = require('supertest');
const app = require('../../app');
const User = require('../../models/User');

describe('Auth API Endpoints', () => {
  it('should register a new company and admin user successfully', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Test Pharmacy',
        email: 'pharmacy@test.com',
        phone: '0102030405',
        address: 'Abidjan',
        city: 'Abidjan',
        country: 'CI',
        fullName: 'Test Admin',
        adminEmail: 'admin@test.com',
        password: 'Password123!',
      });

    expect(res.statusCode).toEqual(201);
    expect(res.body.data).toHaveProperty('user');
    expect(res.body.data.user).toHaveProperty('email', 'admin@test.com');
    
    // Check if user is in database
    const userInDb = await User.findOne({ email: 'admin@test.com' });
    expect(userInDb).toBeTruthy();
    expect(userInDb.fullName).toBe('Test Admin');
  });

  it('should not login with invalid credentials', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'nonexistent@bigpharma.bj',
        password: 'wrongpassword'
      });

    expect(res.statusCode).not.toEqual(200);
  });
});
