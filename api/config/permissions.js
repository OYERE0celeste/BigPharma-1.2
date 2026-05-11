/**
 * Permission Matrix for BigPharma 1.2
 */
const ROLES = {
  ADMINISTRATEUR: "administrateur",
  PHARMACIEN: "pharmacien",
  GESTIONNAIRE_STOCK: "gestionnaire de stock",
  AGENT_VENTE: "agent de vente",
  PERSONNEL_AUTORISE: "personnel autorisé",
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
  
  [ROLES.AGENT_VENTE]: [
    PERMISSIONS.VIEW_PRODUCTS,
    PERMISSIONS.CREATE_SALE,
    PERMISSIONS.VIEW_SALES,
    PERMISSIONS.VIEW_ORDERS,
  ],
  
  [ROLES.PERSONNEL_AUTORISE]: [
    PERMISSIONS.VIEW_PRODUCTS,
    PERMISSIONS.VIEW_ORDERS,
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
