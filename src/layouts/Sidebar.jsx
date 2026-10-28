import { NavLink } from "react-router-dom";
import { Users, User, UserCog, Truck, FileText, CreditCard, ShoppingCart, Store, Receipt, BookOpen, SlidersHorizontal, ShieldCheck } from "lucide-react";
import { useConfig } from "../contexts/ConfigContext";
import { useAuth } from "../contexts/AuthContext";
import {
  getSidebarIconClass,
  getSidebarItemClass,
  GRID_SIDEBAR_NAV_CLASS,
  SIDEBAR_NAV_LIST_CLASS,
  SIDEBAR_MOBILE_CLASS,
} from "../theme/appTheme";

const SECTION_ICONS = {
  Suppliers: Users,
  Customers: User,
  Staff: UserCog,
  Transports: Truck,
  Users: User,
  Configurations: SlidersHorizontal,
  AccessManagement: ShieldCheck,
  "Bill Entry": FileText,
  "Credit Entry": CreditCard,
  "Purchase Entry": ShoppingCart,
  "Retail Entry": Store,
  Bills: Receipt,
  Credit: CreditCard,
  Purchase: ShoppingCart,
  Retail: Store,
  Ledger: BookOpen,
};

const useSidebarMenuItems = (activeSection) => {
  const { config } = useConfig();
  const retailConfig = config?.filter((c) => c.key === "RETAIL_FEATURE");
  const { auth, can, canAny } = useAuth();
  const isAdmin = auth?.role?.includes("ADMIN");
  const canAccessManagement = can("ACCESS_MANAGEMENT_CURD");
  const canConfiguration = can("CONFIGURATIONS");

  if (activeSection === "master") {
    return [
      ...(canAny([
        "SUPPLIER_CREATE",
        "SUPPLIER_DELETE",
        "SUPPLIER_UPDATE",
        "SUPPLIER_VIEW",
      ]) ? [{ name: "Suppliers", path: "/suppliers" }] : []),

        ...(canAny([
        "CUSTOMER_CREATE",
        "CUSTOMER_DELETE",
        "CUSTOMER_UPDATE",
        "CUSTOMER_VIEW",
      ]) ? [{ name: "Customers", path: "/customers" }] : []),

        ...(canAny([
        "STAFF_CREATE",
        "STAFF_DELETE",
        "STAFF_UPDATE",
        "STAFF_VIEW",
      ]) ? [{ name: "Staff", path: "/staff" }] : []),

        ...(canAny([
        "TRANSPORT_CREATE",
        "TRANSPORT_DELETE",
        "TRANSPORT_UPDATE",
        "TRANSPORT_VIEW",
      ]) ? [{ name: "Transports", path: "/transports" }] : []),

        ...(canAny([
        "USER_CREATE",
        "USER_DELETE",
        "USER_UPDATE",
        "USER_VIEW",
      ]) ? [{ name: "Users", path: "/users" }] : []),
      ...(canAccessManagement ? [{ name: "Access Management", path: "/access-management" }] : []),
      ...(canConfiguration ? [{ name: "Configurations", path: "/configurations" }] : []),
    ];
  }

  if (activeSection === "entries") {
    return [
      ...(can("BILL_CREATE")
      ? [{ name: "Bill Entry", path: "/bill-entry" }]
      : []),

    ...(can("CREDIT_CREATE")
      ? [{ name: "Credit Entry", path: "/credit-entry" }]
      : []),

    ...(can("PURCHASE_CREATE")
      ? [{ name: "Purchase Entry", path: "/purchase-entry" }]
      : []),

      ...(retailConfig?.[0]?.value === "true"
        ? [{ name: "Retail Entry", path: "/retail-entry" }]
        : []),
    ];
  }

  if (activeSection === "reporting") {
    return [
      ...(can("BILL_REPORT_VIEW")
      ? [{ name: "Bills", path: "/bills" }]
      : []),

    ...(can("CREDIT_REPORT_VIEW")
      ? [{ name: "Credit", path: "/credits" }]
      : []),

    ...(can("PURCHASE_REPORT_VIEW")
      ? [{ name: "Purchase", path: "/purchase" }]
      : []),

      ...(can("LEDGER_REPORT_VIEW")
      ? [{ name: "Ledger", path: "/ledge" }]
      : []),

      ...(retailConfig?.[0]?.value === "true"
        ? [{ name: "Retail", path: "/retail" }]
        : []),
    ];
  }

  return [];
};

export const SidebarNavList = ({
  activeSection,
  isOpen,
  isMobile,
  onClose,
  safeNavigate,
}) => {
  const menuItems = useSidebarMenuItems(activeSection);

  return (
    <ul
      className={`${SIDEBAR_NAV_LIST_CLASS} ${
        isOpen ? "opacity-100" : "opacity-0 pointer-events-none"
      }`}
    >
      {menuItems.map((item) => {
        const Icon = SECTION_ICONS[item.name] || FileText;

        return (
          <li key={item.name}>
            <NavLink
              to={item.path}
              onClick={(e) => {
                e.preventDefault();
                safeNavigate(item.path);
                if (isMobile) onClose();
              }}
              className={({ isActive }) => getSidebarItemClass(isActive)}
            >
              {({ isActive }) => (
                <>
                  <Icon className={getSidebarIconClass(isActive)} />
                  <span>{item.name}</span>
                </>
              )}
            </NavLink>
          </li>
        );
      })}
    </ul>
  );
};

/** Mobile slide-out drawer only */
const Sidebar = ({
  activeSection,
  isOpen,
  onClose,
  isMobile,
  safeNavigate,
}) => (
  <aside
    className={`
      flex md:hidden flex-col fixed top-16 left-0 bottom-0 z-40 w-64
      transition-transform duration-300 ease-in-out
      ${SIDEBAR_MOBILE_CLASS}
      ${isOpen ? "translate-x-0" : "-translate-x-full"}
    `}
  >
    <div className={`flex-1 min-h-0 overflow-y-auto ${GRID_SIDEBAR_NAV_CLASS}`}>
      <SidebarNavList
        activeSection={activeSection}
        isOpen={isOpen}
        isMobile={isMobile}
        onClose={onClose}
        safeNavigate={safeNavigate}
      />
    </div>
  </aside>
);

export default Sidebar;
