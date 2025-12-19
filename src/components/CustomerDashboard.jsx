import { useEffect, useState, useRef } from "react";
import { Ellipsis, Eye, Trash2, ArrowLeft, ArrowRight, Rows } from "lucide-react";
import { useSnackbar } from "../context/SnackbarContext";

import {
  getCustomers,
  deleteCustomer,
  searchCustomers,
} from "../service/CustomerService";
import AddNewCustomer from "../modals/AddNewCustomer";
import CustomerDetail from "../modals/CustomerDetail";
import UniversalSearch from "../components/UniversalSearch";
import SmartTable from "./SmartTable";

export default function CustomerDashboard() {
  const [openMenuIndex, setOpenMenuIndex] = useState(null);
  const [searchResults, setSearchResults] = useState([]);
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [selectedCustomer, setSelectedCustomer] = useState(null);
  const [open, setOpen] = useState(false);
  const [modalOpen, setModalOpen] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const rowsPerPage = 7;
  const [loading, setLoading] = useState(false);
  const dropdownRef = useRef(null);
  const [customers, setCustomers] = useState([]);
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const searchRef = useRef(null);
  const [clickCount, setClickCount] = useState(0);
  const { showSnackbar } = useSnackbar();
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [customerToDelete, setCustomerToDelete] = useState(null);

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

  useEffect(() => {
    if (!isSearchActive) {
      fetchCustomers(currentPage);
    }
  }, [currentPage, isSearchActive]);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setOpenMenuIndex(null);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

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

  const fetchCustomers = async (page = 1) => {
    setLoading(true);
    try {
      const data = await getCustomers(page, rowsPerPage);
      setCustomers(data.content || []);
      setTotalPages(data.totalPages || 1);
    } catch (error) {
      console.error("Error fetching customers:", error);
      setCustomers([]);
      setTotalPages(1);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (code) => {
    try {
      const response = await deleteCustomer(code);
      showSnackbar(response.message, "success");
      if (isSearchActive) {
        const updated = searchResults.filter((c) => c.code !== code);
        setSearchResults(updated);
        setCustomers(
          updated.slice(
            (currentPage - 1) * rowsPerPage,
            currentPage * rowsPerPage
          )
        );
        setTotalPages(Math.ceil(updated.length / rowsPerPage));
      } else {
        fetchCustomers(currentPage);
      }
    } catch (error) {
      console.error("Error deleting customer:", error);
    }
  };

  const handleChangePage = (page) => {
    setCurrentPage(page);

    if (isSearchActive) {
      const start = (page - 1) * rowsPerPage;
      const end = start + rowsPerPage;
      setCustomers(searchResults.slice(start, end));
    } else {
      fetchCustomers(page);
    }
  };

  const confirmDelete = (customer) => {
    setCustomerToDelete(customer);
    setDeleteModalOpen(true);
    setOpenMenuIndex(null);
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
      <UniversalSearch
        placeholder="Search customers..."
        query={query}
        setQuery={setQuery}
        searchFn={searchCustomers}
        onResult={(results) => {
          setSearchResults(results);
          setCustomers(results);
          setIsSearchActive(results.length > 0 && query.trim() !== "");
          setCurrentPage(1);
          setTotalPages(1);
        }}
      />
      
      <SmartTable
        columns={[
          { label: "Code", accessor: "code" },
          { label: "Name", accessor: "customerName" },
          { label: "GST", accessor: "customerGstNo" },
          { label: "Address", accessor: "address" },
          { label: "City", accessor: "city" },
          {
            label: "Contact Person",
            accessor: (row) => row.contacts?.[0]?.contactPerson || "-",
          },
          {
            label: "Mobile",
            accessor: (row) => row.contacts?.[0]?.mobileNumber || "-",
          },
        ]}
        data={customers}
        loading={loading}
        dropdownRef={dropdownRef}
        openMenuIndex={openMenuIndex}
        setOpenMenuIndex={setOpenMenuIndex}
        onView={(row) => {
          console.log("Selected customers:", row);
          setSelectedCustomer(row);
          setModalOpen(true);
        }}
        onDelete={(row) => confirmDelete(row)}
      />

      {/* Customer Detail Modal */}
      {modalOpen && selectedCustomer && (
        <CustomerDetail
          selectedCustomer={selectedCustomer}
          setModalOpen={setModalOpen}
        />
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="absolute bottom-0 left-0 right-0 text-center p-3">
          <div className="max-w-sm mx-auto flex justify-between items-center space-x-2">
            {/* Always Render Prev */}
            <div>
              <button
                onClick={() => handleChangePage(currentPage - 1)}
                disabled={currentPage === 1}
                className={`w-9 h-9 flex items-center justify-center rounded-full border ${
                  currentPage === 1
                    ? "bg-gray-100 text-gray-400 cursor-not-allowed"
                    : "bg-white hover:bg-gray-200"
                }`}
              >
                <ArrowLeft size={18} />
              </button>
            </div>
            {/* Pagination Numbers */}
            <div className=" flex ">
              {" "}
              {totalPages <= 2 ? (
                [...Array(totalPages)].map((_, i) => (
                  <button
                    key={i}
                    onClick={() => handleChangePage(i + 1)}
                    className={`w-9 h-9 flex items-center justify-center rounded-full border ${
                      currentPage === i + 1
                        ? "bg-blue-600 text-white"
                        : "bg-white hover:bg-gray-200"
                    }`}
                  >
                    {i + 1}
                  </button>
                ))
              ) : (
                <>
                  <button
                    onClick={() => handleChangePage(1)}
                    className={`w-9 h-9 flex items-center justify-center rounded-full border ${
                      currentPage === 1
                        ? "bg-blue-600 text-white"
                        : "bg-white hover:bg-gray-200"
                    }`}
                  >
                    1
                  </button>

                  {currentPage > 3 && (
                    <span className="px-2 text-gray-500">...</span>
                  )}

                  {[currentPage - 1, currentPage, currentPage + 1]
                    .filter((page) => page > 1 && page < totalPages)
                    .map((page) => (
                      <button
                        key={page}
                        onClick={() => handleChangePage(page)}
                        className={`w-9 h-9 flex items-center justify-center rounded-full border ${
                          currentPage === page
                            ? "bg-blue-600 text-white"
                            : "bg-white hover:bg-gray-200"
                        }`}
                      >
                        {page}
                      </button>
                    ))}

                  {currentPage < totalPages - 2 && (
                    <span className="px-2 text-gray-500">...</span>
                  )}

                  <button
                    onClick={() => handleChangePage(totalPages)}
                    className={`w-9 h-9 flex items-center justify-center rounded-full border ${
                      currentPage === totalPages
                        ? "bg-blue-600 text-white"
                        : "bg-white hover:bg-gray-200"
                    }`}
                  >
                    {totalPages}
                  </button>
                </>
              )}
            </div>
            <div>
              {" "}
              {/* Always Render Next */}
              <button
                onClick={() => handleChangePage(currentPage + 1)}
                disabled={currentPage === totalPages}
                className={`w-9 h-9 flex items-center justify-center rounded-full border ${
                  currentPage === totalPages
                    ? "bg-gray-100 text-gray-400 cursor-not-allowed"
                    : "bg-white hover:bg-gray-200"
                }`}
              >
                <ArrowRight size={18} />
              </button>
            </div>
          </div>
        </div>
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

      {/* 🔹 Delete Confirmation Modal */}
      {deleteModalOpen && customerToDelete && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50">
          <div className="bg-white dark:bg-zinc-900 rounded-2xl shadow-2xl w-[380px] p-6 transform transition-all scale-100 animate-fadeIn">
            {/* Header with warning icon */}
            <div className="flex items-center justify-center mb-4">
              <div className="bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 rounded-full p-3">
                <Trash2 size={26} />
              </div>
            </div>

            {/* Title */}
            <h3 className="text-lg font-semibold text-center text-gray-800 dark:text-gray-100 mb-2">
              Delete Customer
            </h3>

            {/* Message */}
            <p className="text-center text-gray-600 dark:text-gray-400 text-sm mb-6">
              Are you sure you want to permanently delete{" "}
              <span className="font-medium text-blue-600 dark:text-blue-400">
                {customerToDelete.customerName}
              </span>
              ? This action cannot be undone.
            </p>

            {/* Buttons */}
            <div className="flex justify-center gap-3">
              <button
                onClick={() => setDeleteModalOpen(false)}
                className="px-4 py-2 rounded-lg border border-gray-300 dark:border-zinc-700 
                     text-gray-700 dark:text-gray-200 hover:bg-gray-100 
                     dark:hover:bg-zinc-800 transition-all duration-150"
              >
                Cancel
              </button>

              <button
                onClick={async () => {
                  await handleDelete(customerToDelete.code);
                  setDeleteModalOpen(false);
                }}
                className="px-4 py-2 rounded-lg bg-red-600 text-white hover:bg-red-700 
                     shadow-sm transition-all duration-150"
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
