import { useState, useRef, useEffect, useCallback } from "react";
import TransportService from "../service/TransportService";
import AddNewTransport from "../modals/AddNewTransport";
import { useSnackbar } from "../context/SnackbarContext";
import UniversalSearch from "../components/UniversalSearch";
import DataTable from "./DataTable";
import useResponsive from "../customHooks/useResponsive";
import DeleteConfirmModal from "./common/DeleteConfirmModal";


export default function TransportDashboard() {
  // throw new Error("error in transport page");
  const [loading, setLoading] = useState(false);
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [open, setOpen] = useState(false);
  const [editingTransport, setEditingTransport] = useState(null);
  const [transports, setTransports] = useState([]);
  const [query, setQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);
  const rowsPerPage = 10;
  const [openMenuIndex, setOpenMenuIndex] = useState(null);
  const [totalItems, setTotalItems] = useState(0);
  const dropdownRef = useRef(null);
  const { showSnackbar } = useSnackbar();
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [transportToDelete, setTransportToDelete] = useState(null);
  const { isMobile } = useResponsive();

  const columns = {
    desktop: [
      {
        key: "name",
        label: "Transport Name",
        width: "20%",
      },
      {
        key: "gstNo",
        label: "GST No.",
        width: "14%",
      },
      {
        key: "contacts",
        label: "Contact",
        width: "14%",
        render: (row) =>
          row.contacts?.length > 0
            ? row.contacts.map(c => c.contactNumber).join(", ")
            : "-",
      },
      {
        key: "city",
        label: "City",
        width: "12%",
        render: (row) => row.city || "-",
      },
      {
        key: "addressLine1",
        label: "Address",
        width: "22%",
        render: (row) =>
          `${row.addressLine1 || ""}${row.addressLine2 ? ", " + row.addressLine2 : ""}` || "-",
      },
      {
        key: "status",
        label: "Status",
        width: "10%",
        render: (row) => {
          const isActive = row.status === "ACTIVE";
          return (
            <span
              className={`inline-flex px-2.5 py-1 text-xs font-medium rounded-full ${isActive
                  ? "bg-green-100 text-green-800 dark:bg-green-800/30 dark:text-green-400"
                  : "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400"
                }`}
            >
              {isActive ? "Active" : "Inactive"}
            </span>
          );
        },
      },
    ],
    mobile: [
      {
        key: "name",
        label: "Transport Name",
      },
      {
        key: "city",
        label: "City",
        render: (row) => row.city || "-",
      }
    ],
  };

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setOpenMenuIndex(null);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const fetchTransports = useCallback(
    async (uiPage = 1) => {
      const backendPage = uiPage - 1;
      setLoading(true);
      try {
        const data = await TransportService.getTransports(
          backendPage,
          rowsPerPage,
        );
        setTransports(data.content || []);
        setTotalPages(data.totalPages || 0);
        setTotalItems(data.totalElements || 0);
        setCurrentPage(uiPage);
      } catch (error) {
        console.error("Error fetching transports:", error);
        setTransports([]);
        setTotalPages(0);
        setTotalItems(0);
        showSnackbar(error.message, "error");
      } finally {
        setLoading(false);
      }
    },
    [rowsPerPage],
  );

  const handleSearchResult = (response, searchQuery) => {
    if (!searchQuery.trim()) {
      setIsSearchActive(false);
      fetchTransports(1);
      return;
    }
    const results = response.content || [];
    setTransports(results);
    setTotalPages(response.totalPages || 0);
    setTotalItems(response.totalElements || 0);
    setIsSearchActive(searchQuery.trim() !== "");
    setCurrentPage(1);
  };

  const handleChangePage = async (newPage) => {
    if (newPage < 1 || (totalPages > 0 && newPage > totalPages)) return;

    setCurrentPage(newPage);

    if (isSearchActive && query.trim()) {
      try {
        const backendPage = newPage - 1;
        const response = await TransportService.searchTransports(
          query,
          backendPage,
          rowsPerPage,
        );

        handleSearchResult(response, query);
      } catch (error) {
        console.error("Error fetching search page:", error);
        showSnackbar(error.message, "error");
      }
    } else {
      fetchTransports(newPage);
    }
  };

  const handleClearSearch = useCallback(() => {
    setQuery("");
    setIsSearchActive(false);
    fetchTransports(1);
  }, [fetchTransports]);

  useEffect(() => {
    if (query.trim() === "" && isSearchActive) {
      handleClearSearch();
    }
  }, [query, isSearchActive, handleClearSearch]);

  useEffect(() => {
    fetchTransports(1);
  }, [fetchTransports]);

  const confirmDelete = (transport) => {
    setTransportToDelete(transport);
    setDeleteModalOpen(true);
    setOpenMenuIndex(null);
  };

  const handleDelete = async () => {
    if (!transportToDelete) return;
    try {
      const result = await TransportService.deleteTransport(
        transportToDelete.id,
      );
      showSnackbar(
        result.message || "Transport deleted successfully",
        "success",
      );

      if (isSearchActive && query.trim()) {
        const backendPage = currentPage - 1;
        const response = await TransportService.searchTransports(
          query,
          backendPage,
          rowsPerPage,
        );

        handleSearchResult(response, query);
      } else {
        fetchTransports(currentPage);
      }
    } catch (error) {
      console.error("Error deleting transport:", error);
      showSnackbar(error.message, "error");
    } finally {
      setDeleteModalOpen(false);
      setTransportToDelete(null);
    }
  };

  const handleEdit = (transport) => {
    setEditingTransport(transport);
    setOpen(true);
  };

  const handleAddNew = () => {
    setEditingTransport(null);
    setOpen(true);
  };

  const handleModalClose = () => {
    setOpen(false);
    setEditingTransport(null);
  };

  const handleSuccess = () => {
    fetchTransports(currentPage);
  };

  return (
    <div className="text-gray-900 dark:text-gray-100 flex flex-col h-full">
      {/* Header Section*/}
      <div className="pt-4">
        <div className="flex justify-between items-center mb-2">
          <h2 className="text-lg md:text-2xl font-bold">{isMobile ? "Transport" : "Transport Overview"}</h2>
          <button
            onClick={handleAddNew}
            className="px-2 py-1 md:px-4 md:py-2 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700"
          >
            Add Transport
          </button>
        </div>
      </div>

      {/* Search Section */}
      <div className="flex items-center gap-2 mb-6">
        <UniversalSearch
          placeholder="Search transports..."
          query={query}
          setQuery={setQuery}
          searchFn={TransportService.searchTransports}
          onResult={handleSearchResult}
          onClear={handleClearSearch}
          suggestionKey="name"
          pageSize={rowsPerPage}
          showSuggestions={false}
        />
      </div>

      {/* Table Section */}
      <div className="flex-1 min-h-0 border mb-2 rounded-lg bg-white dark:bg-zinc-900">
        <DataTable
          columns={isMobile ? columns.mobile : columns.desktop}
          data={transports}
          loading={loading}
          onEdit={(transport) => handleEdit(transport)}
          onDelete={(transport) => {
            setTransportToDelete(transport);
            setDeleteModalOpen(true);
          }}
          emptyMessage="No transports found"
          page={currentPage}
          totalCount={totalItems}
          rowsPerPage={rowsPerPage}
          onPageChange={handleChangePage}
        />
      </div>

      {/* Add / Edit Transport Modal */}
      {open && (
        <AddNewTransport
          open={open}
          setOpen={setOpen}
          editingTransport={editingTransport}
          onSuccess={handleSuccess}
        />
      )}

      <DeleteConfirmModal
        open={deleteModalOpen}
        title="Delete Transport"
        message={
          <>
            Are you sure you want to permanently delete{" "}
            <span className="font-medium text-blue-600">
              {transportToDelete?.name}
            </span>
            ? This action cannot be undone.
          </>
        }
        confirmText="Delete"
        cancelText="Cancel"
        onClose={() => {
          setDeleteModalOpen(false);
          setTransportToDelete(null);
        }}
        onConfirm={() => {
          handleDelete();
          setDeleteModalOpen(false);
          setTransportToDelete(null);
        }}
      />

    </div>
  );
}
