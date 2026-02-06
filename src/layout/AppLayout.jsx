import { useEffect, useState } from "react";
import { Outlet, useNavigate, useLocation } from "react-router-dom";
import Navbar from "../components/Navbar";
import Sidebar from "../components/Sidebar";
import { useMediaQuery } from "@mui/material";

const AppLayout = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [navbarHeight, setNavbarHeight] = useState(0);
  const [activeSection, setActiveSection] = useState(() => {
    if (
      location.pathname.startsWith("/suppliers") ||
      location.pathname.startsWith("/customers") ||
      location.pathname.startsWith("/staff") ||
      location.pathname.startsWith("/users")
    ) {
      return "master";
    }
    if (
      location.pathname.startsWith("/bill-entry") ||
      location.pathname.startsWith("/credit-entry") ||
      location.pathname.startsWith("/purchase-entry")
    ) {
      return "entries";
    }
    if (
      location.pathname.startsWith("/bills") ||
      location.pathname.startsWith("/credits") ||
      location.pathname.startsWith("/purchase")
    ) {
      return "reporting";
    }
    return "master";
  });
  const isMobile = useMediaQuery("(max-width:768px)");


  useEffect(() => {
    if (location.pathname !== "/") {
      localStorage.setItem("lastRoute", location.pathname);
    }
  }, [location.pathname]);


  useEffect(() => {
    if (location.pathname === "/") {
      const lastRoute = localStorage.getItem("lastRoute");

      if (lastRoute && lastRoute !== "/") {
        navigate(lastRoute, { replace: true });
      } else {
        navigate("/suppliers", { replace: true });
      }
    }
  }, [location.pathname, navigate]);


  const handleSectionChange = (section) => {
    setActiveSection(section);
    switch (section) {
      case "master":
        navigate("/suppliers");
        break;
      case "entries":
        navigate("/bill-entry");
        break;
      case "reporting":
        navigate("/bills");
        break;
      default:
        break;
    }
  };

  const closeSidebar = () => setIsSidebarOpen(false);
  const toggleSidebar = () => {
    setIsSidebarOpen((prev) => !prev);
  };

  return (
    <div className="h-screen flex flex-col">
      <Navbar
        onSectionChange={handleSectionChange}
        activeSection={activeSection}
        onMenuClick={toggleSidebar}
        isMobile={isMobile}
        setNavbarHeight={setNavbarHeight}
      />
      <div className="flex flex-1 min-h-0">
        {isSidebarOpen && (
          <div
            className="fixed inset-x-0 bottom-0 bg-black/40 z-30 md:hidden"
            style={{ top: navbarHeight }}
            onClick={closeSidebar}
          />
        )}
        <Sidebar
          activeSection={activeSection}
          isOpen={isSidebarOpen}
          isMobile={isMobile}
          onClose={closeSidebar}
          navbarHeight={navbarHeight}
        />
        <main className=" flex-1 min-h-0 px-4 overflow-hidden ">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default AppLayout;
