import { useEffect, useState } from "react";
import { Outlet, useNavigate, useLocation } from "react-router-dom";
import Navbar from "../components/Navbar";
import Sidebar, { SidebarNavList } from "../components/Sidebar";
import BrandLogo from "../components/common/BrandLogo";
import {
  GRID_SIDEBAR_BRAND_CLASS,
  GRID_SIDEBAR_COLUMN_CLASS,
  GRID_SIDEBAR_NAV_CLASS,
} from "../theme/appTheme";
import { useMediaQuery } from "@mui/material";
import ConfirmDialog from "../components/common/ConfirmDialog";
import { useUnsaved } from "../context/UnsavedChangesContext";

const AppLayout = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [isSidebarOpen, setIsSidebarOpen] = useState(() => {
    if (typeof window === "undefined") return true;
    return window.matchMedia("(min-width: 769px)").matches;
  });
  const activeSection = (() => {
    if (location.pathname.startsWith("/graph")) {
      return "graph";
    }

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
      location.pathname.startsWith("/retail")||
      location.pathname.startsWith("/ledger")
    ) {
      return "reporting";
    }

    return "master";
  })();
  const isGraphPage = activeSection === "graph";
  const isMobile = useMediaQuery("(max-width:768px)");
  const [pendingPath, setPendingPath] = useState(null);
  const [showConfirm, setShowConfirm] = useState(false);
  const { isDirty, setIsDirty } = useUnsaved();
  const entryPaths = ["/bill-entry", "/credit-entry", "/purchase-entry"];
  const isEntryPage = entryPaths.some(path =>
    location.pathname.startsWith(path)
  );

  const showDesktopSidebar = !isGraphPage && !isMobile && isSidebarOpen;

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
      case "graph":
        safeNavigate("/graph");
        break;
      default:
        break;
    }
  };

  const closeSidebar = () => setIsSidebarOpen(false);
  const toggleSidebar = () => {
    setIsSidebarOpen((prev) => !prev);
  };

  useEffect(() => {
    if (isMobile) {
      setIsSidebarOpen(false);
    }
  }, [isMobile]);

  useEffect(() => {
    if (isGraphPage) {
      setIsSidebarOpen(false);
    }
  }, [isGraphPage]);

  const sidebarNavProps = {
    activeSection,
    isOpen: isSidebarOpen,
    isMobile,
    onClose: closeSidebar,
    safeNavigate,
  };

  const gridCols = isGraphPage
    ? "1fr"
    : showDesktopSidebar
      ? "16rem 1fr"
      : "0px 1fr";

  return (
    <div
      className="relative h-screen min-h-0 grid transition-[grid-template-columns] duration-300 ease-in-out"
      style={{
        gridTemplateColumns: gridCols,
        gridTemplateRows: "4rem 1fr",
      }}
    >
      {isSidebarOpen && !isGraphPage && isMobile && (
        <div
          className="fixed inset-0 bg-black/40 z-30 md:hidden"
          onClick={closeSidebar}
        />
      )}

      {!isGraphPage && (
        <>
          <div className={GRID_SIDEBAR_COLUMN_CLASS}>
            <div className={GRID_SIDEBAR_BRAND_CLASS}>
              {showDesktopSidebar && <BrandLogo />}
            </div>
            <div className={GRID_SIDEBAR_NAV_CLASS}>
              {showDesktopSidebar && <SidebarNavList {...sidebarNavProps} />}
            </div>
          </div>
          <Sidebar {...sidebarNavProps} />
        </>
      )}

      <div
        className={`row-start-1 min-w-0 ${
          isGraphPage ? "col-start-1" : "col-start-2"
        }`}
      >
        <Navbar
          onSectionChange={handleSectionChange}
          activeSection={activeSection}
          onMenuClick={toggleSidebar}
          showMenuButton={!isGraphPage}
          className="w-full"
        />
      </div>

      <main
        className={`row-start-2 min-h-0 min-w-0 overflow-hidden px-4 pb-4 bg-white dark:bg-zinc-950 ${
          isGraphPage ? "col-start-1" : "col-start-2"
        }`}
      >
        <Outlet />
      </main>

      <ConfirmDialog
        open={showConfirm}
        onConfirm={handleConfirmLeave}
        onCancel={handleStay}
      />
    </div>
  );
};

export default AppLayout;
