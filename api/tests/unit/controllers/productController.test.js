const productController = require("../../../controllers/productController");
const Product = require("../../../models/product");
const { success, failure } = require("../../../utils/response");

// Mock dependencies
jest.mock("../../../models/product");
jest.mock("../../../models/mouvementStock");
jest.mock("../../../utils/activityLogger");
jest.mock("../../../utils/dbUtils");
jest.mock("../../../utils/response");

describe("Product Controller Unit Tests", () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      query: {},
      params: {},
      body: {},
      user: { companyId: "comp123", fullName: "Test User" },
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
      header: jest.fn().mockReturnThis(),
      attachment: jest.fn().mockReturnThis(),
      send: jest.fn().mockReturnThis(),
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe("getProducts", () => {
    it("should fetch products with default filters and pagination", async () => {
      const mockProducts = [{ name: "Prod 1" }, { name: "Prod 2" }];

      // Mock Product.find chain
      const findMock = {
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        skip: jest.fn().mockResolvedValue(mockProducts),
      };
      Product.find.mockReturnValue(findMock);
      Product.countDocuments.mockResolvedValue(2);

      await productController.getProducts(req, res, next);

      expect(Product.find).toHaveBeenCalledWith({ isActive: true });
      expect(Product.countDocuments).toHaveBeenCalledWith({ isActive: true });
      expect(success).toHaveBeenCalledWith(
        res,
        expect.objectContaining({
          data: mockProducts,
          extra: expect.objectContaining({
            pagination: expect.objectContaining({ total: 2 }),
          }),
        })
      );
    });

    it("should apply companyId filter if provided in query", async () => {
      req.query.companyId = "comp456";
      Product.find.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        skip: jest.fn().mockResolvedValue([]),
      });
      Product.countDocuments.mockResolvedValue(0);

      await productController.getProducts(req, res, next);

      expect(Product.find).toHaveBeenCalledWith(expect.objectContaining({ companyId: "comp456" }));
    });
  });

  describe("getProductById", () => {
    it("should return a product if found and active", async () => {
      const mockProduct = { _id: "p1", name: "Prod 1", isActive: true };
      Product.findById.mockReturnValue({
        populate: jest.fn().mockResolvedValue(mockProduct),
      });
      req.params.id = "p1";

      await productController.getProductById(req, res, next);

      expect(Product.findById).toHaveBeenCalledWith("p1");
      expect(success).toHaveBeenCalledWith(res, { data: mockProduct });
    });

    it("should return 404 if product not found", async () => {
      Product.findById.mockReturnValue({
        populate: jest.fn().mockResolvedValue(null),
      });
      req.params.id = "unknown";

      await productController.getProductById(req, res, next);

      expect(failure).toHaveBeenCalledWith(res, {
        status: 404,
        message: "Produit introuvable",
      });
    });

    it("should return 404 if product is inactive", async () => {
      const mockProduct = { _id: "p1", name: "Prod 1", isActive: false };
      Product.findById.mockReturnValue({
        populate: jest.fn().mockResolvedValue(mockProduct),
      });
      req.params.id = "p1";

      await productController.getProductById(req, res, next);

      expect(failure).toHaveBeenCalledWith(res, {
        status: 404,
        message: "Produit introuvable",
      });
    });
  });
});
