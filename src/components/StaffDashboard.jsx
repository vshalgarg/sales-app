import { useState, useEffect, useCallback } from "react";
import { Calendar, Phone } from "lucide-react";
import dayjs from "dayjs";
import { getStaffs, searchStaffs, deleteStaff, getStaffById } from "../service/StaffService";
import { useSnackbar } from "../context/SnackbarContext";
import AddNewStaff from "../modals/AddNewStaff";
import UniversalSearch from "./UniversalSearch";
import EntityCardGrid from "./common/EntityCardGrid";
import useResponsive from "../customHooks/useResponsive";
import DeleteConfirmModal from "./common/DeleteConfirmModal";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";

const STAFF_CARD_FIELDS = [
  { label: "Phone", key: "phone", icon: Phone },
  { label: "Joining Date", key: "joiningDate", icon: Calendar },
];

const formatJoiningDate = (date) =>
  date && dayjs(date).isValid() ? dayjs(date).format("DD-MM-YYYY") : "-";

export default function StaffDashboard() {
  const [open, setOpen] = useState(false);
  const [searchResults, setSearchResults] = useState([]);
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [staffs, setStaffs] = useState([]);
  const [query, setQuery] = useState("");
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [staffToDelete, setStaffToDelete] = useState(null);
  const { showSnackbar } = useSnackbar();
  const [totalItems, setTotalItems] = useState(0);
  const { isMobile } = useResponsive();
  const [editOpen, setEditOpen] = useState(false);
  const [selectedStaffId, setSelectedStaffId] = useState(null);

  const [form, setForm] = useState({
    staffName: "",
    phone: "",
    joiningDate: "",
  });

  const fetchStaffs = useCallback(async (uiPage = 1) => {
    const backendPage = uiPage - 1;
    try {
      const data = await getStaffs(backendPage, rowsPerPage);

      const formatted = (data.content || []).map((s) => ({
        ...s,
        joiningDate: formatJoiningDate(s.joiningDate),
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
    }
  }, [rowsPerPage, showSnackbar]);

  useEffect(() => {
    fetchStaffs(1);
  }, [fetchStaffs]);

  const handleSearchResult = (response, searchQuery, page = 1) => {
    const results = (response.content || []).map((s) => ({
      ...s,
      joiningDate: formatJoiningDate(s.joiningDate),
    }));

    setStaffs(results);
    setTotalPages(response.totalPages || 1);
    setTotalItems(response.totalElements || 0);
    setIsSearchActive(searchQuery.trim() !== "");
    setCurrentPage(page);
  };

  const handleRowsPerPageChange = async (newSize) => {
    setRowsPerPage(newSize);
    setCurrentPage(1);

    if (isSearchActive && query.trim()) {
      try {
        const response = await searchStaffs(query, 0, newSize);
        handleSearchResult(response, query, 1);
      } catch (error) {
        showSnackbar(error.message, "error");
      }
    }
  };

  const handleChangePage = async (newPage) => {
    if (newPage < 1 || (totalPages > 0 && newPage > totalPages)) return;

    setCurrentPage(newPage);

    if (isSearchActive && query.trim()) {
      try {
        const backendPage = newPage - 1;
        const response = await searchStaffs(
          query,
          backendPage,
          rowsPerPage,
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
          (s) => s.staffId !== staffToDelete.staffId,
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
    } finally {
      setDeleteModalOpen(false);
      setStaffToDelete(null);
    }
  };

  const handleClearSearch = useCallback(() => {
    setQuery("");
    setIsSearchActive(false);
    fetchStaffs(1);
  }, [fetchStaffs]);

  const handleEditStaff = async (staffId) => {
    try {
      const data = await getStaffById(staffId);

      setForm({
        staffName: data.staffName || "",
        phone: data.phone || "",
        joiningDate: data.joiningDate
          ? dayjs(data.joiningDate).format("YYYY-MM-DD")
          : "",
      });

      setSelectedStaffId(staffId);
      setEditOpen(true);
    } catch (error) {
      showSnackbar(error.message, "error");
    }
  };

  const buildStaffCardProps = (staff) => ({
    title: staff.staffName,
    fields: STAFF_CARD_FIELDS.map(({ label, key, icon }) => ({
      label,
      icon,
      value: staff[key],
    })),
    onEdit: () => handleEditStaff(staff.staffId),
    onDelete: () => {
      setStaffToDelete(staff);
      setDeleteModalOpen(true);
    },
  });

  return (
    <div className="text-gray-900 dark:text-gray-100 flex flex-col h-full">
      <div>
        <div className="flex justify-between items-center mt-1 mb-3 gap-3">
          <h2 className={PAGE_TITLE_CLASS}>
            {isMobile ? "Staff" : "Staff Overview"}
          </h2>
          <button
            onClick={() => {
              setForm({
                staffName: "",
                phone: "",
                joiningDate: "",
              });
              setOpen(true);
            }}
            className="px-3 py-1.5 md:px-4 md:py-2 bg-brand-primary text-white rounded-lg shadow hover:bg-brand-primary-dark whitespace-nowrap text-sm md:text-base"
          >
            + Add Staff
          </button>
        </div>

        <div className="mb-3">
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
      </div>

      <div className="flex-1 min-h-0 mb-2">
        <EntityCardGrid
          items={staffs}
          getItemKey={(staff) => staff.staffId}
          buildCardProps={buildStaffCardProps}
          emptyMessage="No staff found"
          page={currentPage}
          totalCount={isSearchActive ? searchResults.length : totalItems}
          rowsPerPage={rowsPerPage}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleRowsPerPageChange}
          entityLabel="staff"
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
        onConfirm={handleDelete}
      />

      {open && (
        <AddNewStaff
          open={open}
          setOpen={setOpen}
          form={form}
          setForm={setForm}
          fetchStaffs={fetchStaffs}
          isEdit={false}
        />
      )}

      {editOpen && (
        <AddNewStaff
          open={editOpen}
          setOpen={setEditOpen}
          form={form}
          setForm={setForm}
          fetchStaffs={fetchStaffs}
          isEdit={true}
          staffId={selectedStaffId}
        />
      )}
    </div>
  );
}
