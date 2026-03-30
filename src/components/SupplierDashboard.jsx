import { useState, useRef, useEffect, useCallback } from "react";
import SupplierService from "../service/SupplierService";
import AddNewSupplier from "../modals/AddNewSupplier";
import SupplierDetail from "../modals/SupplierDetail";
import { useSnackbar } from "../context/SnackbarContext";
import UniversalSearch from "../components/UniversalSearch";
import DataTable from "./DataTable";
import { Typography } from "@mui/material";
import useResponsive from "../customHooks/useResponsive";
import DeleteConfirmModal from "./common/DeleteConfirmModal";
import UpdateSupplierModal from "../modals/UpdateSupplierModal";
import CopyDetailsModal from "./common/CopyDetailsModal";
import { getSupplierFormattedText } from "../utils/copyFormatter";


export default function SupplierDashboard() {
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [open, setOpen] = useState(false);
  const [suppliers, setSuppliers] = useState([]);
  const [query, setQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);
  const rowsPerPage = 10;
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


  const handleCopyDetails = (supplier) => {
    setSupplierToCopy(supplier);
    setCopyModalOpen(true);
  };

  const columns = {
    desktop: [
      { key: "supplierName", label: "Name", width: "22%" },
      { key: "supplierGstNo", label: "GST", width: "16%" },
      {
        key: "address",
        label: "Address",
        width: "26%",
        render: (row) => (
          <Typography
            variant="body2"
            noWrap
            title={row.address}
            sx={{ maxWidth: 200 }}
          >
            {row.address || "-"}
          </Typography>
        ),
      },
      { key: "city", label: "City", width: "12%" },
      
      {
        key: "mobile",
        label: "Mobile",
        width: "20%",
        render: (row) => row.contacts?.[0]?.mobileNumber || "-",
      },
    ],
    mobile: [
      { key: "supplierName", label: "Name" },
      { key: "city", label: "City" },
    ],
  };

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
      } finally {
      }
    },
    [rowsPerPage],
  );

  const handleSearchResult = (response, searchQuery, page = 1) => {
    const results = response.content || [];
    setSuppliers(results);
    setTotalPages(response.totalPages || 0);
    setTotalItems(response.totalElements || 0);
    setIsSearchActive(searchQuery.trim() !== "");
    setCurrentPage(page);
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
      {/* Header Section */}
      <div>
        <div className="flex justify-between items-center my-2">
          <h2 className=" text-lg md:text-2xl font-bold">{isMobile ? "Supplier" : "Supplier Overview"}</h2>
          <button
            onClick={() => setOpen(true)}
            className="px-2 py-1 md:px-4 md:py-2 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700"
          >
            Add Supplier
          </button>
        </div>

        {/* Search Section */}
        <div className="flex items-center mb-2">
          <UniversalSearch
            placeholder="Search suppliers ..."
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

      {/* Table Section*/}
      <div className="flex-1 min-h-0  border rounded-lg mb-2 bg-white dark:bg-zinc-900">
        <DataTable
          columns={isMobile ? columns.mobile : columns.desktop}
          data={suppliers}
          onView={(supplier) => {
            setSelectedSupplier(supplier.id);
            setIsModalOpen(true);
          }}
          onEdit={(supplier) => {
            setEditingSupplierId(supplier.id);
            setOpenEdit(true);
          }}
          onDelete={(supplier) => {
            setSupplierToDelete(supplier);
            setDeleteModalOpen(true);
          }}
          onCopy={handleCopyDetails}
          emptyMessage="No suppliers found"
          page={currentPage}
          totalCount={totalItems}
          rowsPerPage={rowsPerPage}
          onPageChange={handleChangePage}
        />
      </div>

      {/* Modals */}
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
