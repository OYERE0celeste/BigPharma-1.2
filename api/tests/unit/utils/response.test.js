const { success, failure } = require("../../../utils/response");

describe("Response Utility", () => {
  let res;

  beforeEach(() => {
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
  });

  describe("success", () => {
    it("should return 200 and success: true by default", () => {
      success(res);
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        data: null,
      });
    });

    it("should include custom status and data", () => {
      const data = { id: 1, name: "Test" };
      success(res, { status: 201, data });
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        data,
      });
    });

    it("should include extra field if provided", () => {
      const extra = { count: 10 };
      success(res, { extra });
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        data: null,
        extra,
      });
    });
  });

  describe("failure", () => {
    it("should return 400 and success: false by default", () => {
      failure(res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: "Erreur",
        code: "ERROR",
      });
    });

    it("should include custom status, message, and code", () => {
      failure(res, { status: 404, message: "Not Found", code: "NOT_FOUND" });
      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: "Not Found",
        code: "NOT_FOUND",
      });
    });

    it("should include data field if provided", () => {
      const data = { errors: ["Invalid email"] };
      failure(res, { data });
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: "Erreur",
        code: "ERROR",
        data,
      });
    });
  });
});
