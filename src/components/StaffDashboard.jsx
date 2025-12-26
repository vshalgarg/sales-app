import { useState, useEffect, useRef, useCallback } from "react";
import { Trash2 } from "lucide-react";
import { getStaffs, searchStaffs, deleteStaff } from "../service/StaffService";
import { useSnackbar } from "../context/SnackbarContext";
import AddNewStaff from "../modals/AddNewStaff";
import PaginationComponent from "./PaginationComponenet";

export default function StaffDashboard() {
  const [open, setOpen] = useState(false);
  const [searchResults, setSearchResults] = useState([]);
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [loading, setLoading] = useState(false);
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
  const [totalItems, setTotalItems] = useState(0);

  const [form, setForm] = useState({
    staffName: "",
    phone: "",
    joiningDate: "",
  });

  const fetchStaffs = useCallback(async (uiPage = 1) => {
    const backendPage = uiPage - 1;
    setLoading(true);
    try {
      const data = await getStaffs(backendPage, rowsPerPage);
      setStaffs(data.content || []);
      setTotalPages(data.totalPages || 1);
      setTotalItems(data.totalElements || 0);
      setCurrentPage(uiPage);
      setIsSearchActive(false);
      setSearchResults([]);
    } catch (error) {
      console.error("Error fetching staffs:", error);
      setStaffs([]);
      setTotalPages(1);
      setTotalItems(0);
      showSnackbar("Error loading staffs", "error");
    } finally {
      setLoading(false);
    }
  }, [rowsPerPage, showSnackbar]);

  useEffect(() => {
    fetchStaffs(1);
  }, [fetchStaffs]);

  const handleChangePage = async (newPage) => {
    if (newPage < 1 || (totalPages > 0 && newPage > totalPages)) return;
    
    setCurrentPage(newPage);
    
    if (isSearchActive) {
      const start = (newPage - 1) * rowsPerPage;
      const end = start + rowsPerPage;
      setStaffs(searchResults.slice(start, end));
    } else {
      fetchStaffs(newPage);
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
        
        const start = (currentPage - 1) * rowsPerPage;
        const end = start + rowsPerPage;
        setStaffs(updated.slice(start, end));
        setTotalPages(Math.ceil(updated.length / rowsPerPage));
        setTotalItems(updated.length);
      } else {
        fetchStaffs(currentPage);
      }
    } catch (error) {
      console.error("Error deleting staff:", error);
      showSnackbar("Failed to delete staff", "error");
    }
  };

  const handleInputChange = async (e) => {
    const value = e.target.value;
    setQuery(value);

    if (!value.trim()) {
      handleClearSearch();
      return;
    }

    if (value.length > 1) {
      try {
        const result = await searchStaffs(value);
        if (result && result.length) {
          const names = result.map((staff) => staff.staffName);
          setSuggestions(names);
          setIsDropdownOpen(true);
        } else {
          setSuggestions([]);
          setIsDropdownOpen(false);
        }
      } catch (err) {
        console.error(err);
        setSuggestions([]);
      }
    } else {
      setSuggestions([]);
      setIsDropdownOpen(false);
    }
  };

  const handleSuggestionClick = async (name) => {
    setQuery(name);
    setSuggestions([]);
    setIsDropdownOpen(false);
    try {
      const result = await searchStaffs(name);
      if (result && result.length) {
        setSearchResults(result);
        setIsSearchActive(true);
        setTotalPages(Math.ceil(result.length / rowsPerPage));
        setTotalItems(result.length);
        
        const start = 0;
        const end = start + rowsPerPage;
        setStaffs(result.slice(start, end));
        setCurrentPage(1);
      }
    } catch (err) {
      console.error(err);
      showSnackbar("Error loading staff details", "error");
    }
  };
    
  const handleKeyDown = async (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      if (!query.trim()) {
        handleClearSearch();
        return;
      }
      try {
        const result = await searchStaffs(query.trim());
        if (result && result.length) {
          setSearchResults(result);
          setIsSearchActive(true);
          setTotalPages(Math.ceil(result.length / rowsPerPage));
          setTotalItems(result.length);
          
          const start = 0;
          const end = start + rowsPerPage;
          setStaffs(result.slice(start, end));
          setCurrentPage(1);
        } else {
          setStaffs([]);
          setIsSearchActive(true);
          setTotalPages(1);
          setTotalItems(0);
        }
        setSuggestions([]);
        setIsDropdownOpen(false);
      } catch (err) {
        console.error(err);
        showSnackbar("Error searching staff", "error");
      }
    }
  };

  const handleClearSearch = useCallback(() => {
    setQuery("");
    setIsSearchActive(false);
    setSearchResults([]);
    setSuggestions([]);
    setIsDropdownOpen(false);
    fetchStaffs(1);
  }, [fetchStaffs]);

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
      <div className="flex items-center gap-2 mb-6">
        <div ref={searchRef} className="relative w-1/2">
          <input
            type="text"
            value={query}
            onChange={handleInputChange}
            onKeyDown={handleKeyDown}
            onFocus={() => query.length > 1 && setIsDropdownOpen(true)}
            placeholder="Search staff by name..."
            className="w-full border rounded-lg p-2 bg-white dark:bg-gray-800 pr-10"
          />
          
          {/* Clear button inside search input */}
          {query && (
            <button
              onClick={handleClearSearch}
              className="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
            >
              ✕
            </button>
          )}
          
          {/* Suggestions dropdown */}
          {isDropdownOpen && suggestions.length > 0 && (
            <ul className="absolute bg-white dark:bg-gray-800 border rounded-lg shadow w-full mt-1 z-10 max-h-60 overflow-y-auto">
              {suggestions.map((s, idx) => (
                <li
                  key={idx}
                  className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 cursor-pointer"
                  onClick={() => handleSuggestionClick(s)}
                >
                  {s}
                </li>
              ))}
            </ul>
          )}
        </div>
        
        {/*Clear search button outside */}
        {isSearchActive && (
          <button
            onClick={handleClearSearch}
            className="px-4 py-2 text-sm border rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          >
            Clear Search
          </button>
        )}
      </div>

      {/* Staff Table */}
      <div className="relative mt-6 rounded-lg shadow bg-white dark:bg-gray-900">
        {loading && (
          <div className="absolute inset-0 bg-white/80 dark:bg-gray-900/80 z-10 flex items-center justify-center">
            <div className="flex flex-col items-center gap-2">
              <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-blue-600"></div>
              <p className="text-gray-600 dark:text-gray-400">Loading staff...</p>
            </div>
          </div>
        )}

        <table className="min-w-full table-auto text-sm text-left">
          <thead className="bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 uppercase text-xs">
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
                <tr key={i} className="border-t border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800">
                  <td className="px-6 py-2">{s.staffId}</td>
                  <td className="px-6 py-2">{s.staffName}</td>
                  <td className="px-6 py-2">{s.phone}</td>
                  <td className="px-6 py-2">{s.joiningDate}</td>
                  <td className="px-6 py-2">
                    <button
                      onClick={() => {
                        setStaffToDelete(s);
                        setDeleteModalOpen(true);
                      }}
                      className="text-red-600 hover:text-red-800 dark:hover:text-red-400"
                      title="Delete Staff"
                    >
                      <Trash2 className="w-5 h-5" />
                    </button>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="5" className="text-center text-gray-500 dark:text-gray-400 py-4">
                  {loading ? "Loading..." : "No staff found"}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination*/}
      {(totalPages > 1 || (isSearchActive && searchResults.length > rowsPerPage)) && (
        <div className="mt-6">
          <PaginationComponent
            currentPage={currentPage}
            totalPages={totalPages}
            totalItems={isSearchActive ? searchResults.length : totalItems}
            onPageChange={handleChangePage}
            showInfo={false}
          />
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {deleteModalOpen && staffToDelete && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50">
          <div className="bg-white dark:bg-zinc-900 rounded-2xl shadow-2xl w-[380px] p-6">
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
                         dark:hover:bg-zinc-800"
              >
                Cancel
              </button>
              <button
                onClick={handleDelete}
                className="px-4 py-2 rounded-lg bg-red-600 text-white hover:bg-red-700"
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
  );
}