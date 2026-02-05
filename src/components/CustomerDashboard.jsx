import { useEffect, useState, useRef, useCallback } from "react";
import { useSnackbar } from "../context/SnackbarContext";
import CustomerService from "../service/CustomerService";
import AddNewCustomer from "../modals/AddNewCustomer";
import CustomerDetail from "../modals/CustomerDetail";
import UniversalSearch from "../components/UniversalSearch";
import DataTable from "./DataTable";
import { useMediaQuery } from "@mui/material";
import useResponsive from "../customHooks/useResponsive";

export default function CustomerDashboard() {
  const [openMenuIndex, setOpenMenuIndex] = useState(null);
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [selectedCustomer, setSelectedCustomer] = useState(null);
  const [open, setOpen] = useState(false);
  const [modalOpen, setModalOpen] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);
  const rowsPerPage = 10;
  const [loading, setLoading] = useState(false);
  const dropdownRef = useRef(null);
  const [customers, setCustomers] = useState([]);
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const searchRef = useRef(null);
  const { showSnackbar } = useSnackbar();
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [customerToDelete, setCustomerToDelete] = useState(null);
  const [totalItems, setTotalItems] = useState(0);
  const { isMobile } = useResponsive();

  const [form, setForm] = useState({
    customerName: "",
    email: "",
    customerGroup: "",
    customerGstNo: "",
    customerMsme: "",
    referencedBy: "",
    addressLine1: "",
    addressLine2: "",
    state: "",
    city: "",
    pinCode: "",
    contacts: [{ contactPerson: "", mobileNumber: "", type: "" }],
    preferredTransportIds: [],
    remark: "",
  });

  const columns = {
    desktop: [
      { key: "customerName", label: "Name", width: "18%" },
      { key: "customerGstNo", label: "GST", width: "14%" },
      {
        key: "address",
        label: "Address",
        width: "26%",
        render: (row) => (
          <div className="truncate max-w-[200px]" title={row.address}>
            {row.address || "-"}
          </div>
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
      { key: "customerName", label: "Name"},
      { key: "city", label: "City"},
    ],
  };

  const fetchCustomers = useCallback(
    async (uiPage = 1) => {
      const backendPage = uiPage - 1;
      setLoading(true);
      try {
        const data = await CustomerService.getCustomers(
          backendPage,
          rowsPerPage,
        );
        setCustomers(data.content || []);
        setTotalPages(data.totalPages || 0);
        setTotalItems(data.totalElements || 0);
        setCurrentPage(uiPage);
        setIsSearchActive(false);
      } catch (error) {
        setCustomers([]);
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
    setCustomers(results);
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
        const response = await CustomerService.searchCustomers(
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
      fetchCustomers(newPage);
    }
  };

  const handleClearSearch = useCallback(() => {
    setQuery("");
    setSuggestions([]);
    setIsSearchActive(false);
    fetchCustomers(1);
  }, [fetchCustomers]);

  useEffect(() => {
    if (!query.trim() && isSearchActive) {
      handleClearSearch();
    }
  }, [query, isSearchActive, handleClearSearch]);

  useEffect(() => {
    fetchCustomers(1);
  }, [fetchCustomers]);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setOpenMenuIndex(null);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (searchRef.current && !searchRef.current.contains(e.target)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleDelete = async () => {
    if (!customerToDelete) return;
    try {
      const response = await CustomerService.deleteCustomer(
        customerToDelete.code,
      );
      showSnackbar(response.message, "success");
      fetchCustomers(currentPage);
    } catch (error) {
      console.error("Error deleting customer:", error);
      showSnackbar(error.message, "error");
    } finally {
      setDeleteModalOpen(false);
      setCustomerToDelete(null);
    }
  };

  return (
    <div className="text-gray-900 flex flex-col dark:text-gray-100 h-full">
      {/* Header Section*/}
      <div className="pt-4">
        <div className="flex justify-between items-center mb-2">
          <h2 className="text-lg md:text-2xl font-bold">
            {isMobile ? "Customer" : "Customer Overview"}
          </h2>
          <button
            onClick={() => setOpen(true)}
            className="px-2 py-1 md:px-4 md:py-2 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700"
          >
            Add Customer
          </button>
        </div>

        {/* Search Section */}
        <div className="flex items-center gap-2 mb-2 md:mb-6">
          <UniversalSearch
            placeholder="Search customers..."
            query={query}
            setQuery={setQuery}
            searchFn={CustomerService.searchCustomers}
            onResult={handleSearchResult}
            onClear={handleClearSearch}
            suggestionKey="customerName"
            pageSize={rowsPerPage}
            showSuggestions={false}
          />
        </div>
      </div>

      {/* Table Section */}
      <div className="flex-1 min-h-0 border rounded-lg mb-2 bg-white dark:bg-zinc-900">
        <DataTable
          columns={isMobile ? columns.mobile : columns.desktop}
          data={customers}
          loading={loading}
          onView={(customer) => {
            setSelectedCustomer(customer);
            setModalOpen(true);
          }}
          onDelete={(customer) => {
            setCustomerToDelete(customer);
            setDeleteModalOpen(true);
          }}
          emptyMessage="No customers found"
          page={currentPage}
          totalCount={totalItems}
          rowsPerPage={rowsPerPage}
          onPageChange={handleChangePage}
        />
      </div>

      {/* Modals*/}
      {modalOpen && selectedCustomer && (
        <CustomerDetail
          selectedCustomer={selectedCustomer}
          setModalOpen={setModalOpen}
        />
      )}

      {open && (
        <AddNewCustomer
          open={open}
          form={form}
          setOpen={setOpen}
          setForm={setForm}
          fetchCustomers={fetchCustomers}
        />
      )}

      {/* Delete Confirmation Modal*/}
      {deleteModalOpen && customerToDelete && (
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
              Delete Customer
            </h3>

            <p className="text-center text-gray-600 dark:text-gray-400 text-sm mb-6">
              Are you sure you want to permanently delete{" "}
              <span className="font-medium text-blue-600 dark:text-blue-400">
                {customerToDelete.customerName}
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
    </div>
  );
}
