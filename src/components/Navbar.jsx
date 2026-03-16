import { Settings, MoonStar, SunMedium, LogOut, User, Menu } from "lucide-react";
import { useEffect, useState, useRef } from "react";
import { useNavigate } from "react-router-dom";

export default function Navbar({
  activeSection,
  onSectionChange,
  onMenuClick,
  isMobile,
  setNavbarHeight,
}) {
  const navRef = useRef(null);
  const [name, setName] = useState("");
  const [userId, setUserId] = useState("");
  const [mainActiveSection, setMainActiveSection] = useState(activeSection);
  const [showLogoutModal, setShowLogoutModal] = useState(false);
  const [showProfileModal, setShowProfileModal] = useState(false);
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const [theme, setTheme] = useState(localStorage.getItem("theme") || "light");

  const navigate = useNavigate();

  useEffect(() => {
    if (theme === "dark") document.documentElement.classList.add("dark");
    else document.documentElement.classList.remove("dark");

    localStorage.setItem("theme", theme);
  }, [theme]);

  useEffect(() => {
    if (!navRef.current) return;

    const updateHeight = () => {
      setNavbarHeight(navRef.current.offsetHeight);
    };

    updateHeight();

    window.addEventListener("resize", updateHeight);
    return () => window.removeEventListener("resize", updateHeight);
  }, [setNavbarHeight]);

  const toggleTheme = () =>
    setTheme((prev) => (prev === "light" ? "dark" : "light"));

  useEffect(() => {
    const storedName = localStorage.getItem("username");
    const storedId = localStorage.getItem("userId");
    if (storedName) setName(storedName);
    if (storedId) setUserId(storedId);
  }, []);

  const handleLogout = () => {
    localStorage.clear();
    navigate("/");
  };

  const handleSectionClick = (sectionName) => {
    setMainActiveSection(sectionName);
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
      {/*Top Navbar */}
      <nav
        ref={navRef}
        className="flex justify-between items-center
       p-3 w-full bg-white dark:bg-zinc-900 
       shadow border-b border-gray-300 dark:border-gray-700 
        transition-colors
    relative z-50
"
      >
        {/* Left: App Title + Section Buttons */}
        <div className="flex items-center">
          <Menu onClick={onMenuClick} className="w-5 h-5 md:w-8 md:h-8 md:hidden mr-3 text-gray-700 dark:text-white" />

          {
            isMobile ? <div className="flex justify-center">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth={2}
                stroke="#6c63ff"
                className="w-7 h-7"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M12 4l6 8H6l6-8zM6 20h12"
                />
              </svg>
            </div> : <h1 className="ml-4 text-xl font-bold text-blue-600 dark:text-blue-400 tracking-wide">
              Hisabio
            </h1>
          }
          {/* Section Buttons */}
          <div className="hidden md:flex space-x-3 md:ml-[200px]">
            {["master", "entries", "reporting"].map((section) => (
              <button
                key={section}
                onClick={() => handleSectionClick(section)}
                className={`px-3 py-1 rounded-md font-medium transition-colors
                  ${mainActiveSection === section
                    ? "bg-blue-600 text-white"
                    : "text-gray-700 dark:text-white hover:text-blue-600 dark:hover:text-blue-400"
                  }`}
              >
                {section.charAt(0).toUpperCase() + section.slice(1)}
              </button>
            ))}
          </div>
          {/* Mobile section dropdown */}
          <div className="relative md:hidden ml-3">
            <select
              value={mainActiveSection}
              onChange={(e) => handleSectionClick(e.target.value)}
              className="px-3 pr-8 min-h-[36px] leading-normal whitespace-normal rounded-md border
 bg-white dark:bg-zinc-800 text-gray-800 dark:text-white border-gray-300 dark:border-zinc-700
    appearance-none
  "
            >

              <option value="master">Master</option>
              <option value="entries">Entries</option>
              <option value="reporting">Reporting</option>
            </select>

            <span
              className="pointer-events-none absolute right-2  inset-y-0 flex items-center text-gray-500 text-xs
    "
            >
              ▼
            </span>
          </div>
        </div>

        {/* Right: Profile Menu */}
        <div className="relative profile-dropdown">
          <Settings onClick={() => setShowProfileMenu(!showProfileMenu)} className="w-5 h-5 md:w-8 md:h-8 text-gray-700 dark:text-white" />

          {/* Dropdown */}
          {showProfileMenu && (
            <div
              className="absolute right-0 mt-2 w-40 md:w-48
             bg-white dark:bg-zinc-800 shadow-lg rounded-lg border
              border-gray-200 dark:border-zinc-700 py-2 z-50"
            >
              {/*Theme Toggle */}
              {/* <button
                onClick={toggleTheme}
                className="flex items-center w-full px-4 py-2 hover:bg-gray-100 dark:hover:bg-zinc-700 text-gray-800 dark:text-white"
              >
                {theme === "light" ? (
                  <MoonStar className="w-4 h-4" />
                ) : (
                  <SunMedium className="w-4 h-4 text-yellow-400" />
                )} */}
              {/* <span className="ml-2">
                  {theme === "light" ? "Dark Mode" : "Light Mode"}
                </span>
              </button> */}

              {/*Profile */}
              <button
                onClick={() => {
                  setShowProfileMenu(false);
                  setShowProfileModal(true);
                }}
                className="flex items-center w-full text-left px-4 py-2 hover:bg-gray-100 dark:hover:bg-zinc-700 text-gray-800 dark:text-white"
              >
                <User className="w-4 h-4 mr-2" /> My Profile
              </button>

              {/*Logout */}
              <button
                onClick={() => {
                  setShowProfileMenu(false);
                  setShowLogoutModal(true);
                }}
                className="flex items-center w-full text-left px-4 py-2 text-red-600 hover:bg-gray-100 dark:hover:bg-zinc-700 dark:text-red-400"
              >
                <LogOut className="w-4 h-4 mr-2" /> Logout
              </button>
            </div>
          )}
        </div>
      </nav>

      {/*Profile Modal */}
      {showProfileModal && (
        <div className="fixed inset-0 flex items-center justify-center bg-black/50 z-50">
          <div className="bg-white dark:bg-zinc-800 rounded-lg shadow-lg p-6 w-[360px] mx-4 md:mx-0
">
            <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
              My Profile
            </h2>

            <div className="space-y-2 text-gray-800 dark:text-gray-100">
              <p>
                <strong>Username:</strong> {name || "Not available"}
              </p>
            </div>

            <div className="flex justify-end mt-5">
              <button
                onClick={() => setShowProfileModal(false)}
                className="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/*Logout Confirmation Modal */}
      {showLogoutModal && (
        <div className="fixed inset-0 flex items-center justify-center bg-black/50 z-50">
          <div className="bg-white dark:bg-zinc-800 rounded-lg shadow-lg p-6 w-[320px]">
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-4">
              Are you sure you want to logout?
            </h2>

            <div className="flex justify-end space-x-3">
              <button
                onClick={() => setShowLogoutModal(false)}
                className="px-4 py-2 rounded bg-gray-200 hover:bg-gray-300 dark:bg-zinc-700 dark:hover:bg-zinc-600 text-gray-800 dark:text-white"
              >
                Cancel
              </button>

              <button
                onClick={handleLogout}
                className="px-4 py-2 rounded bg-red-600 hover:bg-red-700 text-white"
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
