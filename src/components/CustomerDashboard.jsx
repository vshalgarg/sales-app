import { useEffect, useState, useRef, useCallback } from "react";
import { Ellipsis, Eye, Trash2 } from "lucide-react";
import { useSnackbar } from "../context/SnackbarContext";
import CustomerService from "../service/CustomerService";
import AddNewCustomer from "../modals/AddNewCustomer";
import CustomerDetail from "../modals/CustomerDetail";
import UniversalSearch from "../components/UniversalSearch";
import PaginationComponent from "./PaginationComponenet";

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

  const [form, setForm] = useState({
    customerName: "",
    customerGroup: "",
    customerGstNo: "",
    customerMsme: "",
    referencedBy: "",
    addressLine1: "",
    addressLine2: "",
    state: "",
    city: "",
    pinCode: "",
    contacts: [{ contactPerson: "", mobileNumber: "", phone: "" }],
    preferredTransportIds: [],
    remark: "",
  });

  const fetchCustomers = useCallback(async (uiPage = 1) => {
    const backendPage = uiPage - 1;
    setLoading(true);
    try {
      const data = await CustomerService.getCustomers(backendPage, rowsPerPage);
      setCustomers(data.content || []);
      setTotalPages(data.totalPages || 0);
      setTotalItems(data.totalElements || 0);
      setCurrentPage(uiPage);
      setIsSearchActive(false);
    } catch (error) {
      console.error("Error fetching customers:", error);
      setCustomers([]);
      setTotalPages(0);
      setTotalItems(0);
      showSnackbar("Error loading customers", "error");
    } finally {
      setLoading(false);
    }
  }, [rowsPerPage, showSnackbar]);

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
          rowsPerPage
        );
        handleSearchResult(response, query);
      } catch (error) {
        console.error("Error fetching search page:", error);
        showSnackbar("Error loading search results", "error");
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

  const confirmDelete = (customer) => {
    setCustomerToDelete(customer);
    setDeleteModalOpen(true);
    setOpenMenuIndex(null);
  };

  const handleDelete = async () => {
    if (!customerToDelete) return;
    try {
      const response = await CustomerService.deleteCustomer(customerToDelete.code);
      showSnackbar(response.message, "success");
      fetchCustomers(currentPage);
    } catch (error) {
      console.error("Error deleting customer:", error);
      showSnackbar("Failed to delete customer.", "error");
    } finally {
      setDeleteModalOpen(false);
      setCustomerToDelete(null);
    }
  };

  return (
    <div className="text-gray-900 dark:text-gray-100">
      <div className="flex justify-between items-center mb-6 h-[8vh]">
        <h2 className="text-2xl font-bold">Customer Overview</h2>
        <button
          onClick={() => setOpen(true)}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700"
        >
          Add New Customer
        </button>
      </div>

      <div className="flex items-center gap-2 mb-6">
        <UniversalSearch
          placeholder="Search customers..."
          query={query}
          setQuery={setQuery}
          searchFn={CustomerService.searchCustomers}
          onResult={handleSearchResult}
          onClear={handleClearSearch}
          suggestionKey="customerName"
          pageSize={rowsPerPage}
        />
        {isSearchActive && (
          <button
            onClick={handleClearSearch}
            className="px-4 py-2 text-sm border rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800"
          >
            Clear
          </button>
        )}
      </div>

      {/* Table Section - Original Design */}
      <div className="relative mt-6 rounded-lg shadow bg-white dark:bg-gray-900">
        <table className="min-w-full table-fixed text-sm text-left">
          <thead className="bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 uppercase text-xs">
            <tr>
              <th className="px-6 py-3 w-[10%]">Code</th>
              <th className="px-6 py-3 w-[15%]">Name</th>
              <th className="px-6 py-3 w-[12%]">GST</th>
              <th className="px-6 py-3 w-[20%]">Address</th>
              <th className="px-6 py-3 w-[10%]">City</th>
              <th className="px-6 py-3 w-[12%]">Contact Person</th>
              <th className="px-6 py-3 w-[11%]">Mobile</th>
              <th className="px-6 py-3 w-[10%]">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="8" className="text-center py-8">
                  <div className="flex justify-center">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                  </div>
                </td>
              </tr>
            ) : customers.length > 0 ? (
              customers.map((c, i) => (
                <tr
                  key={i}
                  className="border-t border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800"
                >
                  <td className="px-6 py-2">{c.code || `C00${i + 1}`}</td>
                  <td className="px-6 py-2">{c.customerName}</td>
                  <td className="px-6 py-2">{c.customerGstNo}</td>
                  <td className="px-6 py-2">{c.address}</td>
                  <td className="px-6 py-2">{c.city}</td>
                  <td className="px-6 py-2">
                    {c.contacts?.[0]?.contactPerson || "-"}
                  </td>
                  <td className="px-6 py-2">
                    {c.contacts?.[0]?.mobileNumber || "-"}
                  </td>
                  <td className="px-6 py-2 relative">
                    <button
                      onClick={() =>
                        setOpenMenuIndex(openMenuIndex === i ? null : i)
                      }
                      className="text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
                    >
                      <Ellipsis />
                    </button>

                    {openMenuIndex === i && (
                      <div
                        ref={dropdownRef}
                        className="absolute bg-white dark:bg-gray-800 border dark:border-gray-700 rounded shadow-md mt-1 z-10 w-22"
                      >
                        <button
                          onClick={() => {
                            setSelectedCustomer(c);
                            setModalOpen(true);
                            setOpenMenuIndex(null);
                          }}
                          className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700"
                        >
                          <Eye className="w-5 h-5 text-gray-600 dark:text-gray-300" />
                        </button>
                        <button
                          onClick={() => confirmDelete(c)}
                          className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100 dark:hover:bg-gray-700"
                        >
                          <Trash2 className="w-5 h-5 text-red-600" />
                        </button>
                      </div>
                    )}
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td
                  colSpan="8"
                  className="text-center text-gray-500 dark:text-gray-400 py-4"
                >
                  No Customers Found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination - Using PaginationComponent */}
      {totalPages > 0 && (
        <div className="mt-6">
          <PaginationComponent
            currentPage={currentPage}
            totalPages={totalPages}
            totalItems={totalItems}
            onPageChange={handleChangePage}
            showInfo={false}
          />
        </div>
      )}

      {/* Customer Detail Modal */}
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

      {/* Delete Confirmation Modal */}
      {deleteModalOpen && customerToDelete && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50">
          <div className="bg-white dark:bg-zinc-900 rounded-2xl shadow-2xl w-[380px] p-6">
            <div className="flex items-center justify-center mb-4">
              <div className="bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 rounded-full p-3">
                <Trash2 size={26} />
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