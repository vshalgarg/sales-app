import { useState, useEffect, useRef, useCallback } from "react";
import { Trash2 } from "lucide-react";
import { getStaffs, searchStaffs, deleteStaff } from "../service/StaffService";
import { useSnackbar } from "../context/SnackbarContext";
import AddNewStaff from "../modals/AddNewStaff";
import DataTable from "./DataTable";
import UniversalSearch from "./UniversalSearch";
import dayjs from "dayjs";

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


  const columns = [

    {
      key: "staffName",
      label: "Staff Name",
      width: "40%",
    },
    {
      key: "phone",
      label: "Phone",
      width: "30%",
    },
    {
      key: "joiningDate",
      label: "Joining Date",
      width: "30%",
    },
  ];


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

    const formatted = (data.content || []).map((s) => ({
      ...s,
      joiningDate: s.joiningDate
        ? dayjs(s.joiningDate).isValid()
          ? dayjs(s.joiningDate).format("DD-MM-YYYY")
          : "-"
        : "-",
    }));

    setStaffs(formatted);
    setTotalPages(data.totalPages || 1);
    setTotalItems(data.totalElements || 0);
    setCurrentPage(uiPage);
    setIsSearchActive(false);
    setSearchResults([]);
  } catch (error) {
    setStaffs([]);
    setTotalPages(1);
    setTotalItems(0);
    showSnackbar(error.message, "error");
  } finally {
    setLoading(false);
  }
}, [rowsPerPage]);


  useEffect(() => {
    fetchStaffs(1);
  }, [fetchStaffs]);

  const handleChangePage = async (newPage) => {
    if (newPage < 1 || (totalPages > 0 && newPage > totalPages)) return;

    setCurrentPage(newPage);

    if (isSearchActive && query.trim()) {
      try {
        const backendPage = newPage - 1;
        const response = await searchStaffs(
          query,
          backendPage,
          rowsPerPage
        );
        handleSearchResult(response, query);
      } catch (error) {
        console.error("Error fetching search page:", error);
        showSnackbar(error.message, "error");
      }
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
      showSnackbar(error.message, "error");
    }
  };

  const handleClearSearch = useCallback(() => {
    setQuery("");
    setIsSearchActive(false);
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


  const handleSearchResult = (response, searchQuery) => {
    console.log("response and searchQuery"+response+searchQuery)
    const results = response.content || [];
    console.log(results)
    setStaffs(results);
    setTotalPages(response.totalPages || 1);
    setTotalItems(response.totalElements || 0);
    setIsSearchActive(searchQuery.trim() !== "");
    setCurrentPage(1);
  };


  return (
    <div className="text-gray-900 dark:text-gray-100 flex flex-col h-full">
      <div className="pt-4">
      <div className="flex justify-between items-center mb-2">
        <h2 className="text-2xl font-bold">Staff Overview</h2>
        <button
          onClick={() => setOpen(true)}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700"
        >
          Add New Staff
        </button>
      </div>
     </div>
      {/* Search */}
      <div className="flex items-center gap-2 mb-6">
        <UniversalSearch
          placeholder="Search staff..."
          query={query}
          setQuery={setQuery}
          searchFn={searchStaffs}
          onResult={handleSearchResult}
          onClear={handleClearSearch}
          suggestionKey="staffName"
          pageSize={rowsPerPage}
          showSuggestions={false}
        />
      </div>

      {/* Staff Table */}
      <div className="flex-1 min-h-0 border mb-2 rounded-lg bg-white dark:bg-zinc-900">
        <DataTable
          columns={columns}
          data={staffs}
          loading={loading}
          emptyMessage="No staff found"
          page={currentPage}
          totalCount={isSearchActive ? searchResults.length : totalItems}
          rowsPerPage={rowsPerPage}
          onPageChange={handleChangePage}
          onDelete={(staff) => {
            setStaffToDelete(staff);
            setDeleteModalOpen(true);
          }}
        />
      </div>

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