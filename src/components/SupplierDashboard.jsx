import { useState, useEffect, useCallback } from "react";
import { MapPin, MapPinned, Phone, Receipt } from "lucide-react";
import SupplierService from "../service/SupplierService";
import AddNewSupplier from "../modals/AddNewSupplier";
import SupplierDetail from "../modals/SupplierDetail";
import { useSnackbar } from "../context/SnackbarContext";
import UniversalSearch from "../components/UniversalSearch";
import EntityCardGrid from "./common/EntityCardGrid";
import useResponsive from "../customHooks/useResponsive";
import DeleteConfirmModal from "./common/DeleteConfirmModal";
import UpdateSupplierModal from "../modals/UpdateSupplierModal";
import CopyDetailsModal from "./common/CopyDetailsModal";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";
import { getSupplierFormattedText } from "../utils/copyFormatter";

const SUPPLIER_CARD_FIELDS = [
  { label: "GST", key: "supplierGstNo", icon: Receipt },
  { label: "City", key: "city", icon: MapPin },
  { label: "Mobile", key: "mobile", icon: Phone },
  { label: "Address", key: "address", icon: MapPinned },
];

export default function SupplierDashboard() {
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [open, setOpen] = useState(false);
  const [suppliers, setSuppliers] = useState([]);
  const [query, setQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const { showSnackbar } = useSnackbar();

  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [supplierToDelete, setSupplierToDelete] = useState(null);
  const [totalItems, setTotalItems] = useState(0);
  const [openEdit, setOpenEdit] = useState(false);
  const [editingSupplierId, setEditingSupplierId] = useState(null);
  const { isMobile } = useResponsive();
  const [copyModalOpen, setCopyModalOpen] = useState(false);
  const [supplierToCopy, setSupplierToCopy] = useState(null);

  const [form, setForm] = useState({
    supplierName: "",
    supplierGroup: "",
    supplierGstNo: "",
    supplierMsme: "",
    commissionScheme: "",
    commissionRate: "",
    addressLine1: "",
    addressLine2: "",
    state: "",
    city: "",
    pinCode: "",
    bankName: "",
    ifscCode: "",
    branchName: "",
    accountName: "",
    accountNumber: "",
    contacts: [{ contactPerson: "", mobileNumber: "", phone: "" }],
    preferredTransportIds: [],
    remark: "",
  });

  const handleCopyDetails = async (supplier) => {
    try {
      const response = await SupplierService.getSupplierById(supplier.id);
      setSupplierToCopy(response.data);
      setCopyModalOpen(true);
    } catch (error) {
      console.error("Error fetching supplier details:", error);
      showSnackbar(error.message, "error");
    }
  };

  const buildSupplierCardProps = (supplier) => ({
    code: supplier.code,
    title: supplier.supplierName,
    fields: SUPPLIER_CARD_FIELDS.map(({ label, key, icon }) => ({
      label,
      icon,
      value: supplier[key],
    })),
    onView: () => {
      setSelectedSupplier(supplier.id);
      setIsModalOpen(true);
    },
    onEdit: () => {
      setEditingSupplierId(supplier.id);
      setOpenEdit(true);
    },
    onCopy: () => handleCopyDetails(supplier),
    onDelete: () => {
      setSupplierToDelete(supplier);
      setDeleteModalOpen(true);
    },
  });

  const fetchSuppliers = useCallback(
    async (uiPage = 1) => {
      const backendPage = uiPage - 1;
      try {
        const data = await SupplierService.getSuppliers(
          backendPage,
          rowsPerPage,
        );
        setSuppliers(data.content || []);
        setTotalPages(data.totalPages || 0);
        setTotalItems(data.totalElements || 0);
        setCurrentPage(uiPage);
      } catch (error) {
        console.error("Error fetching suppliers:", error);
        setSuppliers([]);
        setTotalPages(0);
        setTotalItems(0);
        showSnackbar(error.message, "error");
      }
    },
    [rowsPerPage, showSnackbar],
  );

  const handleSearchResult = (response, searchQuery, page = 1) => {
    const results = response.content || [];
    setSuppliers(results);
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
        const response = await SupplierService.searchSuppliers(
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
        const response = await SupplierService.searchSuppliers(
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
      fetchSuppliers(newPage);
    }
  };

  const handleClearSearch = useCallback(() => {
    setQuery("");
    setIsSearchActive(false);
    fetchSuppliers(1);
  }, [fetchSuppliers]);

  useEffect(() => {
    if (query.trim() === "" && isSearchActive) {
      setIsSearchActive(false);
      fetchSuppliers(1);
    }
  }, [query, isSearchActive, fetchSuppliers]);

  const handleDelete = async () => {
    if (!supplierToDelete) return;
    try {
      const response = await SupplierService.deleteSupplier(
        supplierToDelete.code,
      );
      showSnackbar(response.message, "success");
      fetchSuppliers(currentPage);
    } catch (error) {
      console.error("Error deleting supplier:", error);
      showSnackbar(error.message, "error");
    } finally {
      setDeleteModalOpen(false);
      setSupplierToDelete(null);
    }
  };

  useEffect(() => {
    fetchSuppliers(1);
  }, [fetchSuppliers]);

  return (
    <div className="text-gray-900 dark:text-gray-100 flex flex-col h-full">
      <div>
        <div className="flex justify-between items-center mt-1 mb-3 gap-3">
          <h2 className={PAGE_TITLE_CLASS}>
            {isMobile ? "Supplier" : "Supplier Overview"}
          </h2>
          <button
            onClick={() => setOpen(true)}
            className="px-3 py-1.5 md:px-4 md:py-2 bg-brand-primary text-white rounded-lg shadow hover:bg-brand-primary-dark whitespace-nowrap text-sm md:text-base"
          >
            + Add Supplier
          </button>
        </div>

        <div className="mb-3">
          <UniversalSearch
            placeholder="Search suppliers..."
            query={query}
            setQuery={setQuery}
            searchFn={SupplierService.searchSuppliers}
            onResult={handleSearchResult}
            onClear={handleClearSearch}
            suggestionKey="supplierName"
            pageSize={rowsPerPage}
            showSuggestions={false}
          />
        </div>
      </div>

      <div className="flex-1 min-h-0 mb-2">
        <EntityCardGrid
          items={suppliers}
          buildCardProps={buildSupplierCardProps}
          emptyMessage="No suppliers found"
          page={currentPage}
          totalCount={totalItems}
          rowsPerPage={rowsPerPage}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleRowsPerPageChange}
          entityLabel="suppliers"
        />
      </div>

      {isModalOpen && selectedSupplier && (
        <SupplierDetail
          supplierId={selectedSupplier}
          setIsModalOpen={setIsModalOpen}
        />
      )}

      {open && (
        <AddNewSupplier
          open={open}
          form={form}
          setOpen={setOpen}
          setForm={setForm}
          fetchSuppliers={fetchSuppliers}
        />
      )}

      {openEdit && (
        <UpdateSupplierModal
          supplierId={editingSupplierId}
          open={openEdit}
          setOpen={setOpenEdit}
          fetchSuppliers={() => fetchSuppliers(currentPage)}
        />
      )}

      {copyModalOpen && (
        <CopyDetailsModal
          open={copyModalOpen}
          onClose={() => setCopyModalOpen(false)}
          title="Copy Supplier Details"
          formattedText={getSupplierFormattedText(supplierToCopy)}
        />
      )}

      <DeleteConfirmModal
        open={deleteModalOpen}
        title="Delete Supplier"
        message={
          <>
            Are you sure you want to permanently delete{" "}
            <b>{supplierToDelete?.supplierName}</b>?
            This action cannot be undone.
          </>
        }
        confirmText="Delete"
        cancelText="Cancel"
        onClose={() => {
          setDeleteModalOpen(false);
          setSupplierToDelete(null);
        }}
        onConfirm={handleDelete}
      />
    </div>
  );
}
