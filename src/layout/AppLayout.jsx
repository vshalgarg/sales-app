import { useEffect, useRef, useState } from "react";
import { Outlet, useNavigate, useLocation } from "react-router-dom";
import Navbar from "../components/Navbar";
import Sidebar from "../components/Sidebar";
import { useMediaQuery } from "@mui/material";
import ConfirmDialog from "../components/common/ConfirmDialog";
import { useUnsaved } from "../context/UnsavedChangesContext";

const AppLayout = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [navbarHeight, setNavbarHeight] = useState(0);
  const activeSection = (() => {
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
      location.pathname.startsWith("/purchase-entry") ||
      location.pathname.startsWith("/retail-entry")
    ) {
      return "entries";
    }

    if (
      location.pathname.startsWith("/bills") ||
      location.pathname.startsWith("/credits") ||
      location.pathname.startsWith("/purchase")||
      location.pathname.startsWith("/retail") ||
      location.pathname.startsWith("/reports")
    ) {
      return "reporting";
    }

    return "master";
  })();
  const isMobile = useMediaQuery("(max-width:768px)");
  const [pendingPath, setPendingPath] = useState(null);
  const [showConfirm, setShowConfirm] = useState(false);
  const { isDirty, setIsDirty } = useUnsaved();
  const entryPaths = ["/bill-entry", "/credit-entry", "/purchase-entry"];
  const isEntryPage = entryPaths.some(path =>
    location.pathname.startsWith(path)
  );


  const safeNavigate = (path) => {
    if (isDirty && isEntryPage) {
      setPendingPath(path);
      setShowConfirm(true);
      return;
    }

    navigate(path);
  };

const handleConfirmLeave = () => {
  setShowConfirm(false);
  setIsDirty(false);
  console.log("app layout == ",isDirty)
  navigate(pendingPath);
};

  const handleStay = () => {
    setShowConfirm(false);
    setPendingPath(null);
  };

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

    switch (section) {
      case "master":
        safeNavigate("/suppliers");
        break;
      case "entries":
        safeNavigate("/bill-entry");
        break;
      case "reporting":
        safeNavigate("/bills");
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
          safeNavigate={safeNavigate}
        />
        <main className=" flex-1 min-h-0 px-4 overflow-hidden ">
          <Outlet />
        </main>
      </div>

      <ConfirmDialog
        open={showConfirm}
        onConfirm={handleConfirmLeave}
        onCancel={handleStay}
      />
    </div>
  );
};

export default AppLayout;
