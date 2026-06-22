import { NavLink } from "react-router-dom";
import { useConfig } from "../context/ConfigContext";
import { useAuth } from "../context/AuthContext";

const Sidebar = ({
  activeSection,
  isOpen,
  onClose,
  isMobile,
  navbarHeight,
  safeNavigate,
}) => {
  let menuItems = [];
  const { config } = useConfig();
  const retailConfig = config?.filter((c) => c.key === "RETAIL_FEATURE");
  const { auth } = useAuth();
  const isAdmin = auth?.role?.includes("ADMIN");

  if (activeSection === "master") {
    menuItems = [
      { name: "Suppliers", path: "/suppliers" },
      { name: "Customers", path: "/customers" },
      { name: "Staff", path: "/staff" },
      { name: "Transports", path: "/transports" },
      { name: "Users", path: "/users" },
      ...(isAdmin ? [{ name: "Configurations", path: "/configurations" }] : []),
    ];
  } else if (activeSection === "entries") {
    menuItems = [
      { name: "Bill Entry", path: "/bill-entry" },
      { name: "Credit Entry", path: "/credit-entry" },
      { name: "Purchase Entry", path: "/purchase-entry" },
      ...(retailConfig?.[0]?.value === "true"
        ? [{ name: "Retail Entry", path: "/retail-entry" }]
        : []),
    ];
  } else if (activeSection === "reporting") {
    menuItems = [
      { name: "Bills", path: "/bills" },
      { name: "Credit", path: "/credits" },
      { name: "Purchase", path: "/purchase" },
      ...(retailConfig?.[0]?.value === "true"
        ? [{ name: "Retail", path: "/retail" }]
        : []),
      { name: "Ledger", path: "/ledger" },
    ];
  }

  return (
    <aside
      className={`
        shrink-0 overflow-hidden bg-gray-100 dark:bg-zinc-800
        border-gray-300 dark:border-gray-700 transition-all duration-300 ease-in-out
        fixed bottom-0 left-0 z-40 w-44 p-4 border-r
        transform ${isOpen ? "translate-x-0" : "-translate-x-full"}
        md:static md:z-auto md:transform-none
        ${isOpen ? "md:w-64 md:p-4 md:border-r" : "md:w-0 md:p-0 md:border-0"}
      `}
      style={{ top: isMobile && isOpen ? navbarHeight : undefined }}
    >
      <ul className="w-44 md:w-56 whitespace-nowrap">
        {menuItems.map((item) => (
          <li key={item.name}>
            <NavLink
              to={item.path}
              onClick={(e) => {
                e.preventDefault();
                safeNavigate(item.path);
                if (isMobile) onClose();
              }}
              className={({ isActive }) =>
                `block px-4 py-2 rounded transition-colors
                 text-gray-700 dark:text-white
                 hover:bg-blue-100 dark:hover:bg-blue-800
                 ${
                   isActive ? "bg-blue-200 dark:bg-blue-700 font-semibold" : ""
                 }`
              }
            >
              {item.name}
            </NavLink>
          </li>
        ))}
      </ul>
    </aside>
  );
};

export default Sidebar;
