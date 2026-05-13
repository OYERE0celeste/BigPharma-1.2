const PERMISSIONS = {
  VIEW_DASHBOARD: "view_dashboard",
  VIEW_PRODUCTS: "view_products",
  ADD_PRODUCT: "add_product",
  EDIT_PRODUCT: "edit_product",
  DELETE_PRODUCT: "delete_product",
  VIEW_STOCK: "view_stock",
  EDIT_STOCK: "edit_stock",
  VIEW_STOCK_ALERTS: "view_stock_alerts",
  VIEW_STOCK_REPORTS: "view_stock_reports",
  VIEW_SUPPLIERS: "view_suppliers",
  MAKE_SALE: "make_sale",
  CANCEL_SALE: "cancel_sale",
  VIEW_SALES_HISTORY: "view_sales_history",
  VIEW_CLIENTS: "view_clients",
  ADD_CLIENT: "add_client",
  EDIT_CLIENT: "edit_client",
  DELETE_CLIENT: "delete_client",
  VIEW_ORDERS: "view_orders",
  UPDATE_ORDER_STATUS: "update_order_status",
  VIEW_FINANCIAL_REPORTS: "view_financial_reports",
  ADD_FINANCE_ENTRY: "add_finance_entry",
  MANAGE_USERS: "manage_users",
  MANAGE_PERMISSIONS: "manage_permissions",
  MANAGE_SETTINGS: "manage_settings",
  VIEW_SYSTEM_LOGS: "view_system_logs",
  VIEW_SUPPORT: "view_support",
  RESPOND_SUPPORT: "respond_support",
  VIEW_NOTIFICATIONS: "view_notifications",
};

const ALL_PERMISSIONS = Object.values(PERMISSIONS);

const createPermissionMap = (enabledPermissions = []) =>
  ALL_PERMISSIONS.reduce((acc, permission) => {
    acc[permission] = enabledPermissions.includes(permission);
    return acc;
  }, {});

const ROLE_DEFAULTS = {
  administrateur: createPermissionMap(ALL_PERMISSIONS),
  pharmacien: createPermissionMap([
    PERMISSIONS.VIEW_PRODUCTS,
    PERMISSIONS.ADD_PRODUCT,
    PERMISSIONS.EDIT_PRODUCT,
    PERMISSIONS.VIEW_STOCK,
    PERMISSIONS.VIEW_STOCK_ALERTS,
    PERMISSIONS.VIEW_CLIENTS,
    PERMISSIONS.ADD_CLIENT,
    PERMISSIONS.EDIT_CLIENT,
    PERMISSIONS.VIEW_SALES_HISTORY,
    PERMISSIONS.VIEW_SUPPORT,
    PERMISSIONS.RESPOND_SUPPORT,
    PERMISSIONS.VIEW_ORDERS,
    PERMISSIONS.UPDATE_ORDER_STATUS,
    PERMISSIONS.VIEW_NOTIFICATIONS,
  ]),
  caissier: createPermissionMap([
    PERMISSIONS.VIEW_PRODUCTS,
    PERMISSIONS.MAKE_SALE,
    PERMISSIONS.VIEW_SALES_HISTORY,
    PERMISSIONS.VIEW_CLIENTS,
    PERMISSIONS.ADD_CLIENT,
    PERMISSIONS.VIEW_ORDERS,
    PERMISSIONS.VIEW_NOTIFICATIONS,
  ]),
  "gestionnaire de stock": createPermissionMap([
    PERMISSIONS.VIEW_PRODUCTS,
    PERMISSIONS.ADD_PRODUCT,
    PERMISSIONS.EDIT_PRODUCT,
    PERMISSIONS.VIEW_STOCK,
    PERMISSIONS.EDIT_STOCK,
    PERMISSIONS.VIEW_STOCK_ALERTS,
    PERMISSIONS.VIEW_STOCK_REPORTS,
    PERMISSIONS.VIEW_SUPPLIERS,
    PERMISSIONS.VIEW_NOTIFICATIONS,
  ]),
  "assistante de gestion": createPermissionMap([
    PERMISSIONS.VIEW_PRODUCTS,
    PERMISSIONS.VIEW_STOCK,
    PERMISSIONS.VIEW_SALES_HISTORY,
    PERMISSIONS.VIEW_CLIENTS,
    PERMISSIONS.VIEW_ORDERS,
    PERMISSIONS.VIEW_NOTIFICATIONS,
  ]),
  client: createPermissionMap([]),
};

const SYSTEM_LOCKED = {
  administrateur: [
    PERMISSIONS.MANAGE_USERS,
    PERMISSIONS.MANAGE_PERMISSIONS,
    PERMISSIONS.MANAGE_SETTINGS,
    PERMISSIONS.VIEW_FINANCIAL_REPORTS,
    PERMISSIONS.VIEW_SYSTEM_LOGS,
  ],
  "assistante de gestion": [
    PERMISSIONS.ADD_PRODUCT,
    PERMISSIONS.EDIT_PRODUCT,
    PERMISSIONS.DELETE_PRODUCT,
    PERMISSIONS.EDIT_STOCK,
    PERMISSIONS.MAKE_SALE,
    PERMISSIONS.CANCEL_SALE,
    PERMISSIONS.ADD_FINANCE_ENTRY,
    PERMISSIONS.MANAGE_USERS,
    PERMISSIONS.MANAGE_PERMISSIONS,
    PERMISSIONS.MANAGE_SETTINGS,
  ],
};

const LEGACY_PERMISSION_ALIASES = {
  manage_products: [PERMISSIONS.ADD_PRODUCT, PERMISSIONS.EDIT_PRODUCT, PERMISSIONS.DELETE_PRODUCT],
  manage_stock: [PERMISSIONS.EDIT_STOCK],
  process_sales: [PERMISSIONS.MAKE_SALE],
  cancel_sales: [PERMISSIONS.CANCEL_SALE],
  manage_clients: [PERMISSIONS.ADD_CLIENT, PERMISSIONS.EDIT_CLIENT, PERMISSIONS.DELETE_CLIENT],
  products: [PERMISSIONS.VIEW_PRODUCTS, PERMISSIONS.ADD_PRODUCT, PERMISSIONS.EDIT_PRODUCT, PERMISSIONS.DELETE_PRODUCT],
  sales: [PERMISSIONS.MAKE_SALE, PERMISSIONS.CANCEL_SALE, PERMISSIONS.VIEW_SALES_HISTORY],
  clients: [PERMISSIONS.VIEW_CLIENTS, PERMISSIONS.ADD_CLIENT, PERMISSIONS.EDIT_CLIENT, PERMISSIONS.DELETE_CLIENT],
  finance: [PERMISSIONS.VIEW_FINANCIAL_REPORTS, PERMISSIONS.ADD_FINANCE_ENTRY],
  users: [PERMISSIONS.MANAGE_USERS, PERMISSIONS.MANAGE_PERMISSIONS],
  settings: [PERMISSIONS.MANAGE_SETTINGS],
};

function normalizePermissions(role, rawPermissions = {}) {
  const normalized = {
    ...(ROLE_DEFAULTS[role] || createPermissionMap()),
  };

  if (!rawPermissions || typeof rawPermissions !== "object") {
    return normalized;
  }

  for (const [rawKey, rawValue] of Object.entries(rawPermissions)) {
    const enabled = rawValue === true;
    const mappedKeys = LEGACY_PERMISSION_ALIASES[rawKey] || [rawKey];

    for (const key of mappedKeys) {
      if (ALL_PERMISSIONS.includes(key)) {
        normalized[key] = enabled;
      }
    }
  }

  return normalized;
}

function getRoleDefaults(role) {
  return { ...(ROLE_DEFAULTS[role] || createPermissionMap()) };
}

function sanitizePermissionInput(role, rawPermissions = {}) {
  return normalizePermissions(role, rawPermissions);
}

function resolveUserPermissions(user) {
  if (!user) return createPermissionMap();
  return normalizePermissions(user.role, user.permissions || {});
}

function hasPermission(user, permission) {
  if (!user || !permission) return false;
  return resolveUserPermissions(user)[permission] === true;
}

function hasAnyPermission(user, permissions = []) {
  return permissions.some((permission) => hasPermission(user, permission));
}

module.exports = {
  PERMISSIONS,
  ALL_PERMISSIONS,
  ROLE_DEFAULTS,
  SYSTEM_LOCKED,
  LEGACY_PERMISSION_ALIASES,
  createPermissionMap,
  getRoleDefaults,
  sanitizePermissionInput,
  normalizePermissions,
  resolveUserPermissions,
  hasPermission,
  hasAnyPermission,
};
