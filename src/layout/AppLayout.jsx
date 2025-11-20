import { useEffect, useState } from "react";
import { Outlet, useNavigate, useLocation } from "react-router-dom";
import Navbar from "../components/Navbar";
import Sidebar from "../components/Sidebar";

const AppLayout = () => {
  const navigate = useNavigate();
  const location = useLocation();
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

  useEffect(() => {
    if (location.pathname === "/") {
      setActiveSection("master");
      navigate("/suppliers");
    } else if (
      location.pathname.startsWith("/suppliers") ||
      location.pathname.startsWith("/customers")
    ) {
      setActiveSection("master");
    } else if (location.pathname.startsWith("/bill-entry")) {
      setActiveSection("entries");
    } else if (location.pathname.startsWith("/bill-history")) {
      setActiveSection("reporting");
    }
  }, [location, navigate]);

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

  return (
    <div className="h-screen flex flex-col">
      <Navbar
        onSectionChange={handleSectionChange}
        activeSection={activeSection}
      />
      <div className="flex flex-1">
        <Sidebar className="w-64" activeSection={activeSection} />
        <main className="relative flex-1 h-full px-4 overflow-hidden ">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default AppLayout;
