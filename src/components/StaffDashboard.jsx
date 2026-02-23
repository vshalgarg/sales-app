import { useState, useEffect, useRef, useCallback } from "react";
import { getStaffs, searchStaffs, deleteStaff } from "../service/StaffService";
import { useSnackbar } from "../context/SnackbarContext";
import AddNewStaff from "../modals/AddNewStaff";
import DataTable from "./DataTable";
import UniversalSearch from "./UniversalSearch";
import dayjs from "dayjs";
import useResponsive from "../customHooks/useResponsive";
import DeleteConfirmModal from "./common/DeleteConfirmModal";

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
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [staffToDelete, setStaffToDelete] = useState(null);
  const searchRef = useRef(null);
  const { showSnackbar } = useSnackbar();
  const [totalItems, setTotalItems] = useState(0);
  const { isMobile } = useResponsive();


  const columns = {
    desktop: [

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
    ],
    mobile: [
      {
        key: "staffName",
        label: "Staff Name",
      },
      {
        key: "phone",
        label: "Phone",
      }
    ]
  }

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
        handleSearchResult(response, query, newPage);
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


  const handleSearchResult = (response, searchQuery, page= 1) => {
    const results = response.content || [];
    setStaffs(results);
    setTotalPages(response.totalPages || 1);
    setTotalItems(response.totalElements || 0);
    setIsSearchActive(searchQuery.trim() !== "");
    setCurrentPage(page);
  };


  return (
    <div className="text-gray-900 dark:text-gray-100 flex flex-col h-full">
      <div className="pt-4">
        <div className="flex justify-between items-center mb-2">
          <h2 className="text-lg md:text-2xl font-bold">{isMobile ? "Staff" : "Staff Overview"}</h2>
          <button
            onClick={() => setOpen(true)}
            className="px-2 py-1 md:px-4 md:py-2 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700"
          >
            Add Staff
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
          columns={isMobile ? columns.mobile : columns.desktop}
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

      <DeleteConfirmModal
        open={deleteModalOpen}
        title="Delete Staff"
        message={
          <>
            Are you sure you want to permanently delete{" "}
            <span className="font-medium text-blue-600">
              {staffToDelete?.staffName}
            </span>
            ? This action cannot be undone.
          </>
        }
        confirmText="Delete"
        cancelText="Cancel"
        onClose={() => {
          setDeleteModalOpen(false);
          setStaffToDelete(null);
        }}
        onConfirm={() => {
          handleDelete();
          setDeleteModalOpen(false);
          setStaffToDelete(null);
        }}
      />


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