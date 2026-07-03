import { useState, useEffect, useCallback } from "react";
import { MapPin, Phone, Receipt, MapPinned, CircleDot } from "lucide-react";
import TransportService from "../service/TransportService";
import AddNewTransport from "../modals/AddNewTransport";
import { useSnackbar } from "../context/SnackbarContext";
import UniversalSearch from "../components/UniversalSearch";
import EntityCardGrid from "./common/EntityCardGrid";
import useResponsive from "../customHooks/useResponsive";
import DeleteConfirmModal from "./common/DeleteConfirmModal";
import { getTransportFormattedText } from "../utils/copyFormatter";
import CopyDetailsModal from "./common/CopyDetailsModal";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";

const formatContact = (contacts) =>
  contacts?.length > 0
    ? contacts.map((c) => c.contactNumber).join(", ")
    : "-";

const formatAddress = (transport) => {
  const address = `${transport.addressLine1 || ""}${
    transport.addressLine2 ? `, ${transport.addressLine2}` : ""
  }`;
  return address || "-";
};

const StatusBadge = ({ status }) => {
  const isActive = status === "ACTIVE";
  return (
    <span
      className={`inline-flex px-2.5 py-1 text-xs font-medium rounded-full ${
        isActive
          ? "bg-green-100 text-green-800 dark:bg-green-800/30 dark:text-green-400"
          : "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400"
      }`}
    >
      {isActive ? "Active" : "Inactive"}
    </span>
  );
};

export default function TransportDashboard() {
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [open, setOpen] = useState(false);
  const [editingTransport, setEditingTransport] = useState(null);
  const [transports, setTransports] = useState([]);
  const [query, setQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [totalItems, setTotalItems] = useState(0);
  const { showSnackbar } = useSnackbar();
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [transportToDelete, setTransportToDelete] = useState(null);
  const { isMobile } = useResponsive();
  const [copyModalOpen, setCopyModalOpen] = useState(false);
  const [copyData, setCopyData] = useState(null);

  const fetchTransports = useCallback(
    async (uiPage = 1) => {
      const backendPage = uiPage - 1;
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
      }
    },
    [rowsPerPage, showSnackbar],
  );

  const handleCopy = (transport) => {
    const formatted = getTransportFormattedText(transport);
    setCopyData(formatted);
    setCopyModalOpen(true);
  };

  const handleSearchResult = (response, searchQuery, page = 1) => {
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
    setCurrentPage(page);
  };

  const handleRowsPerPageChange = async (newSize) => {
    setRowsPerPage(newSize);
    setCurrentPage(1);

    if (isSearchActive && query.trim()) {
      try {
        const response = await TransportService.searchTransports(
          query,
          0,
          newSize,
        );
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
        const response = await TransportService.searchTransports(
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

  const handleSuccess = () => {
    fetchTransports(currentPage);
  };

  const buildTransportCardProps = (transport) => ({
    title: transport.name,
    fields: [
      {
        label: "GST No.",
        icon: Receipt,
        value: transport.gstNo,
      },
      {
        label: "Contact",
        icon: Phone,
        value: transport.contacts,
        render: () => formatContact(transport.contacts),
      },
      {
        label: "Address",
        icon: MapPinned,
        value: formatAddress(transport),
      },
      {
        label: "City",
        icon: MapPin,
        value: transport.city,
      },
      {
        label: "Status",
        icon: CircleDot,
        value: transport.status,
        render: () => <StatusBadge status={transport.status} />,
      },
    ],
    onEdit: () => handleEdit(transport),
    onCopy: () => handleCopy(transport),
    onDelete: () => {
      setTransportToDelete(transport);
      setDeleteModalOpen(true);
    },
  });

  return (
    <div className="text-gray-900 dark:text-gray-100 flex flex-col h-full">
      <div>
        <div className="flex justify-between items-center mt-1 mb-3 gap-3">
          <h2 className={PAGE_TITLE_CLASS}>
            {isMobile ? "Transport" : "Transport Overview"}
          </h2>
          <button
            onClick={handleAddNew}
            className="px-3 py-1.5 md:px-4 md:py-2 bg-brand-primary text-white rounded-lg shadow hover:bg-brand-primary-dark whitespace-nowrap text-sm md:text-base"
          >
            + Add Transport
          </button>
        </div>

        <div className="mb-3">
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
      </div>

      <div className="flex-1 min-h-0 mb-2">
        <EntityCardGrid
          items={transports}
          getItemKey={(transport) => transport.id}
          buildCardProps={buildTransportCardProps}
          emptyMessage="No transports found"
          page={currentPage}
          totalCount={totalItems}
          rowsPerPage={rowsPerPage}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleRowsPerPageChange}
          entityLabel="transports"
        />
      </div>

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
        onConfirm={handleDelete}
      />

      <CopyDetailsModal
        open={copyModalOpen}
        onClose={() => setCopyModalOpen(false)}
        title="Transport Details"
        formattedText={copyData}
      />
    </div>
  );
}
