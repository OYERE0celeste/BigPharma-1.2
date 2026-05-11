const Finance = require("../models/finance");
const { success, failure } = require("../utils/response");

exports.getFinanceSummary = async (req, res, next) => {
  try {
    const { start, end } = req.query;
    const query = { companyId: req.user.companyId };

    if (start || end) {
      query.dateTime = {};
      if (start) query.dateTime.$gte = new Date(start);
      if (end) query.dateTime.$lte = new Date(end);
    }

    const transactions = await Finance.find(query).sort({ dateTime: -1 });

    const summary = transactions.reduce((acc, curr) => {
      if (curr.isIncome) acc.totalIncome += curr.amount;
      else acc.totalExpense += curr.amount;
      return acc;
    }, { totalIncome: 0, totalExpense: 0 });

    summary.netProfit = summary.totalIncome - summary.totalExpense;

    // Daily trends (simplified)
    const trends = {};
    transactions.forEach(t => {
      const date = t.dateTime.toISOString().split('T')[0];
      if (!trends[date]) trends[date] = { date, income: 0, expense: 0 };
      if (t.isIncome) trends[date].income += t.amount;
      else trends[date].expense += t.amount;
    });

    return success(res, {
      data: {
        summary,
        trends: Object.values(trends).sort((a, b) => a.date.localeCompare(b.date)),
        transactions: transactions.slice(0, 50) // Return last 50
      }
    });
  } catch (error) {
    next(error);
  }
};

exports.addManualEntry = async (req, res, next) => {
  try {
    const { type, description, amount, isIncome, paymentMethod, dateTime } = req.body;
    
    const entry = await Finance.create({
      type,
      sourceModule: "Manual",
      reference: `MAN-${Date.now()}`,
      description,
      amount,
      isIncome,
      paymentMethod,
      dateTime: dateTime || new Date(),
      employeeName: req.user.fullName,
      companyId: req.user.companyId
    });

    return success(res, { status: 201, data: entry });
  } catch (error) {
    next(error);
  }
};
