import { NavLink } from "react-router-dom";
import {
  Users,
  User,
  UserCog,
  Truck,
  FileText,
  CreditCard,
  ShoppingCart,
  Store,
  Receipt,
  BookOpen,
  SlidersHorizontal,
} from "lucide-react";
import { useConfig } from "../context/ConfigContext";
import { useAuth } from "../context/AuthContext";
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
  const { auth } = useAuth();
  const isAdmin = auth?.role?.includes("ADMIN");

  if (activeSection === "master") {
    return [
      { name: "Suppliers", path: "/suppliers" },
      { name: "Customers", path: "/customers" },
      { name: "Staff", path: "/staff" },
      { name: "Transports", path: "/transports" },
      { name: "Users", path: "/users" },
      ...(isAdmin ? [{ name: "Configurations", path: "/configurations" }] : []),
    ];
  }

  if (activeSection === "entries") {
    return [
      { name: "Bill Entry", path: "/bill-entry" },
      { name: "Credit Entry", path: "/credit-entry" },
      { name: "Purchase Entry", path: "/purchase-entry" },
      ...(retailConfig?.[0]?.value === "true"
        ? [{ name: "Retail Entry", path: "/retail-entry" }]
        : []),
    ];
  }

  if (activeSection === "reporting") {
    return [
      { name: "Bills", path: "/bills" },
      { name: "Credit", path: "/credits" },
      { name: "Purchase", path: "/purchase" },
      ...(retailConfig?.[0]?.value === "true"
        ? [{ name: "Retail", path: "/retail" }]
        : []),
      { name: "Ledger", path: "/ledger" },
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
