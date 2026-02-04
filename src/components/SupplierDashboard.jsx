import { useState, useRef, useEffect, useCallback } from "react";
import SupplierService from "../service/SupplierService";
import AddNewSupplier from "../modals/AddNewSupplier";
import SupplierDetail from "../modals/SupplierDetail";
import { useSnackbar } from "../context/SnackbarContext";
import UniversalSearch from "../components/UniversalSearch";
import DataTable from "./DataTable";
import { Typography, useMediaQuery } from "@mui/material";
import useResponsive from "../customHooks/useResponsive";

export default function SupplierDashboard() {
  const [loading, setLoading] = useState(false);
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [open, setOpen] = useState(false);
  const [suppliers, setSuppliers] = useState([]);
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);
  const rowsPerPage = 10;
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const searchRef = useRef(null);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const { showSnackbar } = useSnackbar();

  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [supplierToDelete, setSupplierToDelete] = useState(null);
  const [totalItems, setTotalItems] = useState(0);
  const dropdownRef = useRef(null);

  const { isMobile } = useResponsive();

  const columns = {
    desktop: [
      { key: "supplierName", label: "Name", width: "18%" },
      { key: "supplierGstNo", label: "GST", width: "14%" },
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
      { key: "city", label: "City", width: "10%" },
      {
        key: "contactPerson",
        label: "Contact Person",
        width: "16%",
        render: (row) => row.contacts?.[0]?.contactPerson || "-",
      },
      {
        key: "mobile",
        label: "Mobile",
        width: "16%",
        render: (row) => row.contacts?.[0]?.mobileNumber || "-",
      },
    ],
    mobile: [
      { key: "supplierName", label: "Name", width: "18%" },
      { key: "city", label: "City", width: "10%" },
    ],
  };

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (searchRef.current && !searchRef.current.contains(e.target)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

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
    contacts: [{ contactPerson: "", mobileNumber: "", phone: "" }],
    preferredTransportIds: [],
    remark: "",
  });

  const fetchSuppliers = useCallback(
    async (uiPage = 1) => {
      const backendPage = uiPage - 1;
      setLoading(true);
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
        setLoading(false);
      }
    },
    [rowsPerPage],
  );

  const handleSearchResult = (response, searchQuery) => {
    const results = response.content || [];
    setSuppliers(results);
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
        const response = await SupplierService.searchSuppliers(
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
      fetchSuppliers(newPage);
    }
  };

  const handleClearSearch = useCallback(() => {
    setQuery("");
    setSuggestions([]);
    setIsSearchActive(false);
    fetchSuppliers(1);
  }, [fetchSuppliers]);

  useEffect(() => {
    if (query.trim() === "" && isSearchActive) {
      setIsSearchActive(false);
      fetchSuppliers(1);
    }
  }, [query, isSearchActive, fetchSuppliers]);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setOpenMenuIndex(null);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

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
          <h2 className=" text-lg md:text-2xl font-bold">{isMobile?"Supplier":"Supplier Overview"}</h2>
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
          columns={isMobile?columns.mobile:columns.desktop}
          data={suppliers}
          loading={loading}
          onView={(supplier) => {
            setSelectedSupplier(supplier);
            setIsModalOpen(true);
          }}
          onDelete={(supplier) => {
            setSupplierToDelete(supplier);
            setDeleteModalOpen(true);
          }}
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
          selectedSupplier={selectedSupplier}
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

      {/* Delete Modal */}
      {deleteModalOpen && supplierToDelete && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50">
          <div className="bg-white dark:bg-zinc-900 rounded-2xl shadow-2xl w-[380px] p-6">
            <div className="flex items-center justify-center mb-4">
              <div className="bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 rounded-full p-3">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-6 w-6"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  strokeWidth={2}
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                  />
                </svg>
              </div>
            </div>

            <h3 className="text-lg font-semibold text-center text-gray-800 dark:text-gray-100 mb-2">
              Delete Supplier
            </h3>

            <p className="text-center text-gray-600 dark:text-gray-400 text-sm mb-6">
              Are you sure you want to permanently delete{" "}
              <span className="font-medium text-blue-600 dark:text-blue-400">
                {supplierToDelete.supplierName}
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
                onClick={() => {
                  handleDelete(supplierToDelete.supplierId);
                  setDeleteModalOpen(false);
                }}
                className="px-4 py-2 rounded-lg bg-red-600 text-white hover:bg-red-700"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
