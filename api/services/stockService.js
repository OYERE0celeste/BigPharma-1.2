const availableStockForProduct = (product) =>
  (product.lots || []).reduce((sum, lot) => sum + (lot.quantityAvailable || 0), 0);

const availableOrderableStockForProduct = (product) => {
  const now = new Date();
  return (product.lots || []).reduce((sum, lot) => {
    if (new Date(lot.expirationDate) < now) {
      return sum;
    }
    return sum + (lot.quantityAvailable || 0);
  }, 0);
};

const allocateStock = (product, quantity) => {
  const now = new Date();
  const eligibleLots = [...(product.lots || [])]
    .filter((lot) => (lot.quantityAvailable || 0) > 0 && new Date(lot.expirationDate) >= now)
    .sort((a, b) => new Date(a.expirationDate) - new Date(b.expirationDate));

  let remaining = quantity;
  const lotAllocations = [];

  for (const lot of eligibleLots) {
    if (remaining <= 0) {
      break;
    }

    const usedQuantity = Math.min(lot.quantityAvailable || 0, remaining);
    if (usedQuantity <= 0) {
      continue;
    }

    lot.quantityAvailable -= usedQuantity;
    remaining -= usedQuantity;
    lotAllocations.push({
      lotId: lot._id,
      quantity: usedQuantity,
    });
  }

  if (remaining > 0) {
    throw new Error(`Stock insuffisant pour ${product.name}`);
  }

  product.stockQuantity = availableStockForProduct(product);

  return lotAllocations;
};

const restoreStock = (product, lotAllocations = []) => {
  for (const allocation of lotAllocations) {
    const lot = product.lots.id(allocation.lotId);
    if (lot) {
      lot.quantityAvailable += allocation.quantity;
    }
  }

  product.stockQuantity = availableStockForProduct(product);
};

module.exports = {
  availableStockForProduct,
  availableOrderableStockForProduct,
  allocateStock,
  restoreStock,
};
