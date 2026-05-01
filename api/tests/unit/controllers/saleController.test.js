const saleController = require("../../../controllers/saleController");
const Sale = require("../../../models/sale");
const Product = require("../../../models/product");
const { success, failure } = require("../../../utils/response");
const { runInTransaction } = require("../../../utils/dbUtils");

// Mock dependencies
jest.mock("../../../models/sale");
jest.mock("../../../models/product");
jest.mock("../../../models/finance");
jest.mock("../../../models/mouvementStock");
jest.mock("../../../utils/activityLogger");
jest.mock("../../../utils/dbUtils");
jest.mock("../../../utils/response");

describe("Sale Controller Unit Tests", () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      body: {},
      user: { companyId: "comp123", fullName: "Test User" },
      params: {},
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    next = jest.fn();

    // Mock runInTransaction to just run the callback
    runInTransaction.mockImplementation(async (callback) => {
      return await callback("mock-session");
    });

    jest.clearAllMocks();
  });

  describe("getSales", () => {
    it("should fetch all sales for the company", async () => {
      const mockSales = [{ invoiceNumber: "INV-1" }, { invoiceNumber: "INV-2" }];
      const findMock = {
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockResolvedValue(mockSales),
      };
      Sale.find.mockReturnValue(findMock);

      await saleController.getSales(req, res, next);

      expect(Sale.find).toHaveBeenCalledWith({ companyId: "comp123" });
      expect(success).toHaveBeenCalledWith(res, { data: mockSales });
    });
  });

  describe("createSale", () => {
    it("should return 400 if items list is empty", async () => {
      req.body.items = [];
      await saleController.createSale(req, res, next);
      expect(failure).toHaveBeenCalledWith(res, {
        status: 400,
        message: "Le panier est vide ou invalide",
      });
    });

    it("should create a sale and deduct stock", async () => {
      const mockItem = { productId: "p1", quantity: 2, unitPrice: 100 };
      req.body.items = [mockItem];
      req.body.totalAmount = 200;

      const mockProduct = {
        _id: "p1",
        name: "Test Product",
        stockQuantity: 10,
        lots: [{ lotNumber: "LOT1", quantityAvailable: 10, expirationDate: new Date() }],
        save: jest.fn().mockResolvedValue(true),
        markModified: jest.fn(),
      };

      Product.findOne.mockReturnValue({
        session: jest.fn().mockResolvedValue(mockProduct),
      });

      // Mock Sale constructor and save
      const mockSaleInstance = {
        _id: "s1",
        invoiceNumber: "INV-123",
        total: 200,
        items: [{ product: "p1", quantity: 2, unitPrice: 100, total: 200 }],
        save: jest
          .fn()
          .mockResolvedValue({ _id: "s1", invoiceNumber: "INV-123", total: 200, items: [] }),
      };
      Sale.mockImplementation(() => mockSaleInstance);

      await saleController.createSale(req, res, next);

      expect(Product.findOne).toHaveBeenCalled();
      expect(mockSaleInstance.save).toHaveBeenCalled();
      expect(success).toHaveBeenCalledWith(res, expect.objectContaining({ status: 201 }));
    });

    it("should throw error if stock is insufficient", async () => {
      const mockItem = { productId: "p1", quantity: 20, unitPrice: 100 };
      req.body.items = [mockItem];

      const mockProduct = {
        _id: "p1",
        name: "Test Product",
        stockQuantity: 10,
      };

      Product.findOne.mockReturnValue({
        session: jest.fn().mockResolvedValue(mockProduct),
      });

      await saleController.createSale(req, res, next);

      // Since runInTransaction throws inside the callback, next(error) should be called
      expect(next).toHaveBeenCalledWith(expect.any(Error));
      expect(next.mock.calls[0][0].message).toBe("Stock insuffisant pour Test Product");
    });
  });
});
