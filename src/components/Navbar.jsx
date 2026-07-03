import { Settings, User, LogOut, Menu } from "lucide-react";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  BRAND_TITLE_CLASS,
  GRID_NAVBAR_CLASS,
  NAV_ICON_BUTTON_CLASS,
  NAV_MENU_ICON_CLASS,
  NAV_TAB_ACTIVE_CLASS,
  NAV_TAB_INACTIVE_CLASS,
  SETTINGS_ICON_CLASS,
} from "../theme/appTheme";

export default function Navbar({
  activeSection,
  onSectionChange,
  onMenuClick,
  showMenuButton = true,
  className = "",
}) {
  const [name, setName] = useState("");
  const [showLogoutModal, setShowLogoutModal] = useState(false);
  const [showProfileModal, setShowProfileModal] = useState(false);
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const mainActiveSection = activeSection;

  const navigate = useNavigate();

  useEffect(() => {
    const storedName = localStorage.getItem("username");
    if (storedName) setName(storedName);
  }, []);

  const handleLogout = () => {
    localStorage.clear();
    navigate("/");
  };

  const sectionLabels = {
    master: "Master",
    entries: "Entries",
    reporting: "Reporting",
    graph: "Monitoring",
  };

  const handleSectionClick = (sectionName) => {
    onSectionChange(sectionName);
  };

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (!e.target.closest(".profile-dropdown")) setShowProfileMenu(false);
    };
    document.addEventListener("click", handleClickOutside);
    return () => document.removeEventListener("click", handleClickOutside);
  }, []);

  return (
    <>
      <nav
        className={`${GRID_NAVBAR_CLASS} transition-colors relative z-30 ${className}`}
      >
        <div className="flex items-center min-w-0 gap-3">
          {showMenuButton && (
            <button
              type="button"
              onClick={onMenuClick}
              aria-label="Toggle menu"
              className={NAV_ICON_BUTTON_CLASS}
            >
              <Menu className={NAV_MENU_ICON_CLASS} />
            </button>
          )}

          <div className="hidden md:flex items-center gap-2">
            {["master", "entries", "reporting", "graph"].map((section) => (
              <button
                key={section}
                type="button"
                onClick={() => handleSectionClick(section)}
                className={`px-4 py-1.5 rounded-lg text-sm font-medium transition-colors ${
                  mainActiveSection === section
                    ? NAV_TAB_ACTIVE_CLASS
                    : NAV_TAB_INACTIVE_CLASS
                }`}
              >
                {sectionLabels[section]}
              </button>
            ))}
          </div>

          <div className="relative md:hidden">
            <select
              value={activeSection}
              onChange={(e) => handleSectionClick(e.target.value)}
              className="px-3 pr-8 min-h-[36px] leading-normal whitespace-normal rounded-lg border appearance-none bg-brand-tab-inactive dark:bg-zinc-800 text-brand-navy dark:text-white border-violet-100 dark:border-zinc-700 text-sm"
            >
              <option value="master">Master</option>
              <option value="entries">Entries</option>
              <option value="reporting">Reporting</option>
              <option value="graph">Monitoring</option>
            </select>

            <span className="pointer-events-none absolute right-2 inset-y-0 flex items-center text-brand-icon text-xs">
              ▼
            </span>
          </div>
        </div>

        <div className="relative profile-dropdown flex items-center shrink-0">
          <button
            type="button"
            onClick={() => setShowProfileMenu(!showProfileMenu)}
            aria-label="Account settings"
            className={NAV_ICON_BUTTON_CLASS}
          >
            <Settings className={SETTINGS_ICON_CLASS} />
          </button>

          {showProfileMenu && (
            <div className="absolute right-0 top-full mt-2 w-40 md:w-48 bg-white dark:bg-zinc-800 shadow-lg rounded-lg border border-violet-100 dark:border-zinc-700 py-2 z-50">
              <button
                type="button"
                onClick={() => {
                  setShowProfileMenu(false);
                  setShowProfileModal(true);
                }}
                className="flex items-center w-full text-left px-4 py-2 hover:bg-brand-tab-inactive dark:hover:bg-zinc-700 text-brand-navy dark:text-white"
              >
                <User className="w-4 h-4 mr-2 shrink-0" /> My Profile
              </button>

              <button
                type="button"
                onClick={() => {
                  setShowProfileMenu(false);
                  setShowLogoutModal(true);
                }}
                className="flex items-center w-full text-left px-4 py-2 text-red-600 hover:bg-brand-tab-inactive dark:hover:bg-zinc-700 dark:text-red-400"
              >
                <LogOut className="w-4 h-4 mr-2 shrink-0" /> Logout
              </button>
            </div>
          )}
        </div>
      </nav>

      {showProfileModal && (
        <div className="fixed inset-0 flex items-center justify-center bg-black/50 z-50">
          <div className="bg-white dark:bg-zinc-800 rounded-lg shadow-lg p-6 w-[360px] mx-4 md:mx-0">
            <h2 className={`text-lg font-semibold mb-4 ${BRAND_TITLE_CLASS}`}>
              My Profile
            </h2>

            <div className="space-y-2 text-brand-navy dark:text-gray-100">
              <p>
                <strong>Username:</strong> {name || "Not available"}
              </p>
            </div>

            <div className="flex justify-end mt-5">
              <button
                type="button"
                onClick={() => setShowProfileModal(false)}
                className="px-4 py-2 rounded-lg bg-brand-primary text-white hover:bg-brand-primary-dark"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {showLogoutModal && (
        <div className="fixed inset-0 flex items-center justify-center bg-black/50 z-50">
          <div className="bg-white dark:bg-zinc-800 rounded-lg shadow-lg p-6 w-[320px]">
            <h2 className={`text-lg font-semibold mb-4 ${BRAND_TITLE_CLASS}`}>
              Are you sure you want to logout?
            </h2>

            <div className="flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setShowLogoutModal(false)}
                className="px-4 py-2 rounded-lg bg-gray-200 hover:bg-gray-300 dark:bg-zinc-700 dark:hover:bg-zinc-600 text-brand-navy dark:text-white"
              >
                Cancel
              </button>

              <button
                type="button"
                onClick={handleLogout}
                className="px-4 py-2 rounded-lg bg-red-600 hover:bg-red-700 text-white"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
