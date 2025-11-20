import { useState, useEffect, useRef } from "react";
import { Trash2, ArrowLeft, ArrowRight } from "lucide-react";
import { getStaffs, searchStaffs, deleteStaff } from "../service/StaffService";
import { useSnackbar } from "../context/SnackbarContext";
import AddNewStaff from "../modals/AddNewStaff";

export default function StaffDashboard() {
  const [open, setOpen] = useState(false);
  const [searchResults, setSearchResults] = useState([]);
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [Loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const rowsPerPage = 10;
  const [staffs, setStaffs] = useState([]);
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [staffToDelete, setStaffToDelete] = useState(null);
  const searchRef = useRef(null);
  const { showSnackbar } = useSnackbar();

  const [form, setForm] = useState({
    staffName: "",
    phone: "",
    joiningDate: "",
  });

  useEffect(() => {
    fetchStaffs();
  }, []);

  const fetchStaffs = async (page = 1) => {
    setLoading(true);
    try {
      const data = await getStaffs(page, rowsPerPage);
      setStaffs(data.content || []);
      setTotalPages(data.totalPages || 1);
    } catch (error) {
      console.error("Error fetching staffs:", error);
      setStaffs([]);
      setTotalPages(1);
    } finally {
      setLoading(false);
    }
  };

  const handleChangePage = (page) => {
    setCurrentPage(page);
    if (isSearchActive) {
      const start = (page - 1) * rowsPerPage;
      const end = start + rowsPerPage;
      setStaffs(searchResults.slice(start, end));
    } else {
      fetchStaffs(page);
    }
  };

  const handleDelete = async () => {
    if (!staffToDelete) return;
    try {
      const response = await deleteStaff(staffToDelete.staffId);
      showSnackbar(response.message, "success");
      setDeleteModalOpen(false);

      if (isSearchActive) {
        const updated = searchResults.filter(
          (s) => s.staffId !== staffToDelete.staffId
        );
        setSearchResults(updated);
        setStaffs(
          updated.slice(
            (currentPage - 1) * rowsPerPage,
            currentPage * rowsPerPage
          )
        );
        setTotalPages(Math.ceil(updated.length / rowsPerPage));
      } else {
        fetchStaffs(currentPage);
      }
    } catch (error) {
      console.error("Error deleting staff:", error);
    }
  };

  const handleInputChange = async (e) => {
    const value = e.target.value;
    setQuery(value);

    if (!value.trim()) {
      setIsSearchActive(false);
      setSearchResults([]);
      setCurrentPage(1);
      fetchStaffs(1);
      setSuggestions([]);
      return;
    }

    if (value.length > 1) {
      try {
        const result = await searchStaffs(value);
        if (result && result.length) {
          const names = result.map((staff) => staff.staffName);
          setSuggestions(names);
        } else {
          setSuggestions([]);
        }
      } catch (err) {
        console.error(err);
        setSuggestions([]);
      }
    } else {
      setSuggestions([]);
    }
  };

  const handleSuggestionClick = async (name) => {
    setQuery(name);
    setSuggestions([]);
    try {
      const result = await searchStaffs(name);
      const selected = result.find((s) => s.staffName === name);
      if (selected) {
        setSearchResults([selected]);
        setStaffs([selected]);
        setIsSearchActive(true);
        setTotalPages(1);
      }
    } catch (err) {
      console.error(err);
    }
  };
    
  const handleKeyDown = async (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      if (!query.trim()) return;
      try {
        const result = await searchStaffs(query.trim());
        setSearchResults(result);
        setIsSearchActive(true);
        setCurrentPage(1);
        setTotalPages(Math.ceil(result.length / rowsPerPage));
        setStaffs(result.slice(0, rowsPerPage));
        setSuggestions([]);
      } catch (err) {
        console.error(err);
      }
    }
  };

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (searchRef.current && !searchRef.current.contains(e.target)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

  return (
    <>
      <div className="text-gray-900 dark:text-gray-100">
        <div className="flex justify-between items-center mb-6 h-[8vh]">
          <h2 className="text-2xl font-bold">Staff Overview</h2>
          <button
            onClick={() => setOpen(true)}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700"
          >
            Add New Staff
          </button>
        </div>

        {/* Search */}
        <div ref={searchRef} className="w-1/2 relative">
          <input
            type="text"
            value={query}
            onChange={handleInputChange}
            onKeyDown={handleKeyDown}
            onFocus={() => setIsDropdownOpen(true)}
            placeholder="Search staff..."
            className="w-full border rounded-lg p-2"
          />
          {isDropdownOpen && suggestions.length > 0 && (
            <ul className="absolute bg-white border rounded-lg shadow-md w-full mt-1 z-10">
              {suggestions.map((s, idx) => (
                <li
                  key={idx}
                  className="p-2 hover:bg-gray-100 cursor-pointer"
                  onClick={() => handleSuggestionClick(s)}
                >
                  {s}
                </li>
              ))}
            </ul>
          )}
        </div>

        {/* Staff Table */}
        <div className="relative mt-6 rounded-lg shadow bg-white">
          <table className="min-w-full table-auto text-sm text-left">
            <thead className="bg-gray-100 text-gray-700 uppercase text-xs">
              <tr>
                <th className="px-6 py-3">Staff Id</th>
                <th className="px-6 py-3">Staff Name</th>
                <th className="px-6 py-3">Phone</th>
                <th className="px-6 py-3">Joining Date</th>
                <th className="px-6 py-3">Action</th>
              </tr>
            </thead>
            <tbody>
              {staffs.length > 0 ? (
                staffs.map((s, i) => (
                  <tr key={i} className="border-t hover:bg-gray-50 relative">
                    <td className="px-6 py-2">{s.staffId}</td>
                    <td className="px-6 py-2">{s.staffName}</td>
                    <td className="px-6 py-2">{s.phone}</td>
                    <td className="px-6 py-2">{s.joiningDate}</td>
                    <td>
                      <button
                        onClick={() => {
                          setStaffToDelete(s);
                          setDeleteModalOpen(true);
                        }}
                        className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
                      >
                        <Trash2 className="w-5 h-5 text-red-600" />
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="8" className="text-center text-gray-500 py-4">
                    No staff found
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* 🔹 Delete Confirmation Modal */}
        {deleteModalOpen && staffToDelete && (
          <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50">
            <div className="bg-white dark:bg-zinc-900 rounded-2xl shadow-2xl w-[380px] p-6 transform transition-all animate-fadeIn">
              <div className="flex items-center justify-center mb-4">
                <div className="bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 rounded-full p-3">
                  <Trash2 className="w-6 h-6" />
                </div>
              </div>

              <h3 className="text-lg font-semibold text-center text-gray-800 dark:text-gray-100 mb-2">
                Delete Staff
              </h3>
              <p className="text-center text-gray-600 dark:text-gray-400 text-sm mb-6">
                Are you sure you want to permanently delete{" "}
                <span className="font-medium text-blue-600 dark:text-blue-400">
                  {staffToDelete.staffName}
                </span>
                ? This action cannot be undone.
              </p>

              <div className="flex justify-center gap-3">
                <button
                  onClick={() => setDeleteModalOpen(false)}
                  className="px-4 py-2 rounded-lg border border-gray-300 dark:border-zinc-700 
                             text-gray-700 dark:text-gray-200 hover:bg-gray-100 
                             dark:hover:bg-zinc-800 transition-all duration-150"
                >
                  Cancel
                </button>
                <button
                  onClick={handleDelete}
                  className="px-4 py-2 rounded-lg bg-red-600 text-white hover:bg-red-700 
                             shadow-sm transition-all duration-150"
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        )}

        {open && (
          <AddNewStaff
            open={open}
            form={form}
            setOpen={setOpen}
            setForm={setForm}
            fetchStaffs={fetchStaffs}
          />
        )}
      </div>
    </>
  );
}
