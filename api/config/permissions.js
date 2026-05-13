/**
 * Permission Matrix for BigPharma 1.2
 */
const ROLES = {
  ADMINISTRATEUR: "administrateur",
  PHARMACIEN: "pharmacien",
  GESTIONNAIRE_STOCK: "gestionnaire de stock",
  CAISSIER: "caissier",
  ASSISTANTE_GESTION: "assistante de gestion",
  CLIENT: "client",
};

const PERMISSIONS = {
  // Products
  VIEW_PRODUCTS: "view_products",
  CREATE_PRODUCT: "create_product",
  UPDATE_PRODUCT: "update_product",
  DELETE_PRODUCT: "delete_product",
  
  // Sales
  CREATE_SALE: "create_sale",
  VIEW_SALES: "view_sales",
  REFUND_SALE: "refund_sale",
  
  // Orders
  VIEW_ORDERS: "view_orders",
  VALIDATE_ORDER: "validate_order",
  PREPARE_ORDER: "prepare_order",
  
  // Users
  MANAGE_USERS: "manage_users",
  VIEW_AUDIT_LOGS: "view_audit_logs",
  
  // Settings
  MANAGE_SETTINGS: "manage_settings",
  BACKUP_DATA: "backup_data",
};

const ROLE_PERMISSIONS = {
  [ROLES.ADMINISTRATEUR]: Object.values(PERMISSIONS),
  
  [ROLES.PHARMACIEN]: [
    PERMISSIONS.VIEW_PRODUCTS,
    PERMISSIONS.CREATE_PRODUCT,
    PERMISSIONS.UPDATE_PRODUCT,
    PERMISSIONS.VIEW_ORDERS,
    PERMISSIONS.VALIDATE_ORDER,
    PERMISSIONS.VIEW_SALES,
    PERMISSIONS.VIEW_AUDIT_LOGS,
  ],
  
  [ROLES.GESTIONNAIRE_STOCK]: [
    PERMISSIONS.VIEW_PRODUCTS,
    PERMISSIONS.UPDATE_PRODUCT,
    PERMISSIONS.VIEW_ORDERS,
    PERMISSIONS.PREPARE_ORDER,
  ],
  
  [ROLES.CAISSIER]: [
    PERMISSIONS.VIEW_PRODUCTS,
    PERMISSIONS.CREATE_SALE,
    PERMISSIONS.VIEW_SALES,
    PERMISSIONS.VIEW_ORDERS,
  ],
  
  [ROLES.ASSISTANTE_GESTION]: [
    PERMISSIONS.VIEW_PRODUCTS,
    PERMISSIONS.VIEW_ORDERS,
    PERMISSIONS.VIEW_SALES,
  ],
  
  [ROLES.CLIENT]: [
    PERMISSIONS.VIEW_PRODUCTS,
  ],
};

module.exports = {
  PERMISSIONS,
  ROLE_PERMISSIONS,
  ROLES,
};
