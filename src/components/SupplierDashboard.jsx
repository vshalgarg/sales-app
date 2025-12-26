import { useState, useRef, useEffect, useCallback } from "react";
import { Ellipsis, Eye, Trash2 } from "lucide-react";
import SupplierService from "../service/SupplierService";
import AddNewSupplier from "../modals/AddNewSupplier";
import SupplierDetail from "../modals/SupplierDetail";
import { useSnackbar } from "../context/SnackbarContext";
import UniversalSearch from "../components/UniversalSearch";
import PaginationComponent from "./PaginationComponenet";

export default function SupplierDashboard() {
  const [loading, setLoading] = useState(false);
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [open, setOpen] = useState(false);
  const [suppliers, setSuppliers] = useState([]);
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);
  const rowsPerPage = 8;
  const [openMenuIndex, setOpenMenuIndex] = useState(null);
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const dropdownRef = useRef(null);
  const searchRef = useRef(null);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const { showSnackbar } = useSnackbar();

  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [supplierToDelete, setSupplierToDelete] = useState(null);
  const [totalItems, setTotalItems] = useState(0);

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

  const fetchSuppliers = useCallback(async (uiPage = 1) => {
    const backendPage = uiPage - 1;
    setLoading(true);
    try {
      const data = await SupplierService.getSuppliers(backendPage, rowsPerPage);
      setSuppliers(data.content || []);
      setTotalPages(data.totalPages || 0);
      setTotalItems(data.totalElements || 0);
      setCurrentPage(uiPage);
    } catch (error) {
      console.error("Error fetching suppliers:", error);
      setSuppliers([]);
      setTotalPages(0);
      setTotalItems(0);
      showSnackbar("Error loading suppliers", "error");
    } finally {
      setLoading(false);
    }
  }, [rowsPerPage, showSnackbar]);

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
          rowsPerPage
        );
        handleSearchResult(response, query);
      } catch (error) {
        console.error("Error fetching search page:", error);
        showSnackbar("Error loading search results", "error");
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

  const confirmDelete = (supplier) => {
    setSupplierToDelete(supplier);
    setDeleteModalOpen(true);
    setOpenMenuIndex(null);
  };

  const handleDelete = async () => {
    if (!supplierToDelete) return;
    try {
      const response = await SupplierService.deleteSupplier(supplierToDelete.code);
      showSnackbar(response.message, "success");
      fetchSuppliers(currentPage);
    } catch (error) {
      console.error("Error deleting supplier:", error);
      showSnackbar("Failed to delete supplier.", "error");
    } finally {
      setDeleteModalOpen(false);
      setSupplierToDelete(null);
    }
  };

  useEffect(() => {
    fetchSuppliers(1);
  }, [fetchSuppliers]);

  return (
    <div className="text-gray-900 dark:text-gray-100">
      {/* Header*/}
      <div className="flex justify-between items-center mb-6 h-[8vh]">
        <h2 className="text-2xl font-bold">Supplier Overview</h2>
        <button
          onClick={() => setOpen(true)}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700"
        >
          Add New Supplier
        </button>
      </div>

      {/* Search*/}
      <div className="flex items-center gap-2 mb-6">
        <UniversalSearch
          placeholder="Search suppliers by name..."
          query={query}
          setQuery={setQuery}
          searchFn={SupplierService.searchSuppliers}
          onResult={handleSearchResult}
          onClear={handleClearSearch}
          suggestionKey="supplierName"
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

      {/* Table*/}
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
            ) : suppliers.length > 0 ? (
              suppliers.map((s, i) => (
                <tr
                  key={i}
                  className="border-t border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800"
                >
                  <td className="px-6 py-2">{s.code || `S00${i + 1}`}</td>
                  <td className="px-6 py-2">{s.supplierName}</td>
                  <td className="px-6 py-2">{s.supplierGstNo}</td>
                  <td className="px-6 py-2">{s.address}</td>
                  <td className="px-6 py-2">{s.city}</td>
                  <td className="px-6 py-2">
                    {s.contacts?.[0]?.contactPerson || "-"}
                  </td>
                  <td className="px-6 py-2">
                    {s.contacts?.[0]?.mobileNumber || "-"}
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
                            setSelectedSupplier(s);
                            setIsModalOpen(true);
                            setOpenMenuIndex(null);
                          }}
                          className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700"
                        >
                          <Eye className="w-5 h-5 text-gray-600 dark:text-gray-300" />
                        </button>
                        <button
                          onClick={() => confirmDelete(s)}
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
                  No Suppliers Found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination*/}
       <div className="mt-6">
        {totalPages > 0 && (
          <PaginationComponent
            currentPage={currentPage}
            totalPages={totalPages}
            totalItems={totalItems}
            onPageChange={handleChangePage}
            showInfo={false}
          />
        )}
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