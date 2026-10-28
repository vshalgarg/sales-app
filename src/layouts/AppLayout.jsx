import { Suspense, useEffect, useState } from "react";
import { Outlet, useNavigate, useLocation } from "react-router-dom";
import Navbar from "./Navbar";
import Sidebar, { SidebarNavList } from "./Sidebar";
import { GRID_SIDEBAR_NAV_CLASS, SHELL_BORDER } from "../theme/appTheme";
import { useMediaQuery } from "@mui/material";
import ConfirmDialog from "../components/ConfirmDialog";
import { useUnsaved } from "../contexts/UnsavedChangesContext";
import { useAuth } from "../contexts/AuthContext";
import { useConfig } from "../contexts/ConfigContext";

const AppLayout = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { can } = useAuth();
  const { config } = useConfig();
  const retailConfig = config?.filter((item) => item.key === "RETAIL_FEATURE");

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
      location.pathname.startsWith("/purchase") ||
      location.pathname.startsWith("/retail") ||
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
  const isEntryPage = entryPaths.some((path) =>
    location.pathname.startsWith(path),
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

      case "entries": {
        const availableEntry = [
          {
            allowed: can("BILL_CREATE"),
            path: "/bill-entry",
          },
          {
            allowed: can("CREDIT_CREATE"),
            path: "/credit-entry",
          },
          {
            allowed: can("PURCHASE_CREATE"),
            path: "/purchase-entry",
          },
          {
            allowed: retailConfig?.[0]?.value === "true",
            path: "/retail-entry",
          },
        ].find((entry) => entry.allowed);

        if (availableEntry) {
          safeNavigate(availableEntry.path);
        }

        break;
      }

      case "reporting": {
        const availableReport = [
          {
            allowed: can("BILL_REPORT_VIEW"),
            path: "/bills",
          },
          {
            allowed: can("CREDIT_REPORT_VIEW"),
            path: "/credits",
          },
          {
            allowed: can("PURCHASE_REPORT_VIEW"),
            path: "/purchase",
          },
          {
            allowed: retailConfig?.[0]?.value === "true",
            path: "/retail",
          },
          {
            allowed: true,
            path: "/ledger",
          },
        ].find((report) => report.allowed);

        if (availableReport) {
          safeNavigate(availableReport.path);
        }

        break;
      }

      case "graph":
        if (can("MONITORING_VIEW")) {
          safeNavigate("/graph");
        }
        break;

      default:
        break;
    }

    if (section !== "graph" && section !== activeSection) {
      setIsSidebarOpen(true);
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

  return (
    <div className="relative h-screen min-h-0 flex flex-col overflow-hidden">
      {isSidebarOpen && !isGraphPage && isMobile && (
        <div
          className="fixed top-16 left-0 right-0 bottom-0 bg-black/40 z-30 md:hidden transition-opacity duration-300"
          onClick={closeSidebar}
        />
      )}

      <div className="shrink-0 z-30">
        <Navbar
          onSectionChange={handleSectionChange}
          activeSection={activeSection}
          onMenuClick={toggleSidebar}
          showMenuButton={!isGraphPage}
          className="w-full"
        />
      </div>

      <div className="flex flex-1 min-h-0 min-w-0">
        {!isGraphPage && (
          <aside
            aria-hidden={!showDesktopSidebar}
            className={`
              hidden md:flex flex-col min-h-0 shrink-0 overflow-hidden
              border-r ${SHELL_BORDER} bg-brand-sidebar dark:bg-zinc-900
              transition-[width,border-color] duration-300 ease-in-out
              ${showDesktopSidebar ? "w-64" : "w-0 border-transparent"}
            `}
          >
            <div
              className={`${GRID_SIDEBAR_NAV_CLASS} min-w-64 transition-opacity duration-300 ${
                showDesktopSidebar
                  ? "opacity-100"
                  : "opacity-0 pointer-events-none"
              }`}
            >
              <SidebarNavList {...sidebarNavProps} />
            </div>
          </aside>
        )}

        {!isGraphPage && <Sidebar {...sidebarNavProps} />}

        <main className="flex-1 min-h-0 min-w-0 overflow-hidden px-4 pb-4 bg-white dark:bg-zinc-950">
          <Suspense fallback={<div className="p-4 text-gray-500">Loading...</div>}>
            <Outlet />
          </Suspense>
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
