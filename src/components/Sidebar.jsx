import { NavLink } from "react-router-dom";

const Sidebar = ({
  activeSection,
  isOpen,
  onClose,
  isMobile,
  navbarHeight,
  safeNavigate
}) => {
  let menuItems = [];

  if (activeSection === "master") {
    menuItems = [
      { name: "Suppliers", path: "/suppliers" },
      { name: "Customers", path: "/customers" },
      { name: "Staff", path: "/staff" },
      { name: "Transports", path: "/transports" },
      { name: "Users", path: "/users" },
    ];
  } else if (activeSection === "entries") {
    menuItems = [
      { name: "Bill Entry", path: "/bill-entry" },
      { name: "Credit Entry", path: "/credit-entry" },
      { name: "Purchase Entry", path: "/purchase-entry" },
      { name: "Retail Entry", path: "/retail-entry" },
    ];
  } else if (activeSection === "reporting") {
    menuItems = [
      // { name: "Bill History", path: "/bill-history" },
      { name: "Bills", path: "/bills" },
      { name: "Credit", path: "/credits" },
      { name: "Purchase", path: "/purchase" },
      { name: "Retail", path: "/retail" },
      { name: "Reports", path: "/reports" },
    ];
  }

  return (
    <aside
      className={`
    w-44 md:w-64 bg-gray-100 dark:bg-zinc-800 p-4 border-r
     border-gray-300 dark:border-gray-700 
     transition-transform duration-300
      fixed bottom-0 left-0 z-40
    transform ${isOpen ? "translate-x-0" : "-translate-x-full"}
    md:relative md:translate-x-0
     `}
      style={{ top: isOpen ? navbarHeight : 0 }}
    >
      <ul>
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
                 ${isActive ? "bg-blue-200 dark:bg-blue-700 font-semibold" : ""
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
