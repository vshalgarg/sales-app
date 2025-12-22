"use client";
import { useState, useRef, useEffect } from "react";
import { Ellipsis, Eye, Trash2, ArrowLeft, ArrowRight } from "lucide-react";
import {
  getSuppliers,
  deleteSupplier,
  searchSuppliers,
} from "../service/SupplierService";
import AddNewSupplier from "../modals/AddNewSupplier";
import SupplierDetail from "../modals/SupplierDetail";
import { useSnackbar } from "../context/SnackbarContext";
import UniversalSearch from "../components/UniversalSearch";

export default function SupplierDashboard() {
  const [loading, setLoading] = useState(false);
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [open, setOpen] = useState(false);
  const [suppliers, setSuppliers] = useState([]);
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const rowsPerPage = 5;
  const [openMenuIndex, setOpenMenuIndex] = useState(null);
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const dropdownRef = useRef(null);
  const searchRef = useRef(null);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const { showSnackbar } = useSnackbar();

  // 🔹 NEW STATES FOR DELETE CONFIRMATION
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [supplierToDelete, setSupplierToDelete] = useState(null);

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

  useEffect(() => {
    if (!isSearchActive) fetchSuppliers(currentPage);
  }, [currentPage, isSearchActive]);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setOpenMenuIndex(null);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const fetchSuppliers = async (page = 1) => {
    setLoading(true);
    try {
      const data = await getSuppliers(page, rowsPerPage);
      console.log("API Response:", data);
      console.log("Content array:", data.content);
      console.log("Total Pages:", data.totalPages);
      setSuppliers(data.content || []);
      setTotalPages(data.totalPages || 1);
    } catch (error) {
      console.error("Error fetching customers:", error);
      setSuppliers([]);
      setTotalPages(1);
    } finally {
      setLoading(false);
    }
  };

  const confirmDelete = (supplier) => {
    setSupplierToDelete(supplier);
    setDeleteModalOpen(true);
    setOpenMenuIndex(null);
  };

  const handleDelete = async () => {
    if (!supplierToDelete) return;
    try {
      const response = await deleteSupplier(supplierToDelete.code);
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

  const handleChangePage = (page) => {
    setCurrentPage(page);
    if (!isSearchActive) fetchSuppliers(page);
  };

  return (
    <div className="text-gray-900 dark:text-gray-100">
      {/* Header */}
      <div className="flex justify-between items-center mb-6 h-[8vh]">
        <h2 className="text-2xl font-bold">Supplier Overview</h2>
        <button
          onClick={() => setOpen(true)}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700"
        >
          Add New Supplier
        </button>
      </div>

      <UniversalSearch
        placeholder="Search suppliers..."
        query={query}
        setQuery={setQuery}
        searchFn={searchSuppliers}
        onResult={(results) => {
          console.log("Res",results)
          setSuppliers(results);
          setIsSearchActive(results.length > 0 && query.trim() !== "");
        }}
      />

      {/* Table */}
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
            {suppliers.length > 0 ? (
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
                            console.log("Selected Supplier:", s);
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

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="absolute bottom-0 left-0 right-0 text-center p-3">
          <div className="max-w-sm mx-auto flex justify-between items-center space-x-2">
            <button
              onClick={() => handleChangePage(currentPage - 1)}
              disabled={currentPage === 1}
              className={`w-9 h-9 flex items-center justify-center rounded-full border ${currentPage === 1
                ? "bg-gray-100 dark:bg-gray-800 text-gray-400 cursor-not-allowed"
                : "bg-white dark:bg-gray-900 hover:bg-gray-200 dark:hover:bg-gray-700"
                }`}
            >
              <ArrowLeft size={18} />
            </button>
            <div className="flex">
              {[...Array(totalPages)].map((_, i) => (
                <button
                  key={i}
                  onClick={() => handleChangePage(i + 1)}
                  className={`w-9 h-9 flex items-center justify-center rounded-full border ${currentPage === i + 1
                    ? "bg-blue-600 text-white"
                    : "bg-white dark:bg-gray-900 hover:bg-gray-200 dark:hover:bg-gray-700"
                    }`}
                >
                  {i + 1}
                </button>
              ))}
            </div>
            <button
              onClick={() => handleChangePage(currentPage + 1)}
              disabled={currentPage === totalPages}
              className={`w-9 h-9 flex items-center justify-center rounded-full border ${currentPage === totalPages
                ? "bg-gray-100 dark:bg-gray-800 text-gray-400 cursor-not-allowed"
                : "bg-white dark:bg-gray-900 hover:bg-gray-200 dark:hover:bg-gray-700"
                }`}
            >
              <ArrowRight size={18} />
            </button>
          </div>
        </div>
      )}

      {/* Supplier Detail Modal */}
      {isModalOpen && selectedSupplier && (
        <SupplierDetail
          selectedSupplier={selectedSupplier}
          setIsModalOpen={setIsModalOpen}
        />
      )}

      {/* Add Supplier Modal */}
      {open && (
        <AddNewSupplier
          open={open}
          form={form}
          setOpen={setOpen}
          setForm={setForm}
          fetchSuppliers={fetchSuppliers}
        />
      )}

      {/* 🔹 Supplier Delete Confirmation Modal */}
      {deleteModalOpen && supplierToDelete && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50">
          <div className="bg-white dark:bg-zinc-900 rounded-2xl shadow-2xl w-[380px] p-6 transform transition-all animate-fadeIn">
            {/* Icon Section */}
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

            {/* Title */}
            <h3 className="text-lg font-semibold text-center text-gray-800 dark:text-gray-100 mb-2">
              Delete Supplier
            </h3>

            {/* Message */}
            <p className="text-center text-gray-600 dark:text-gray-400 text-sm mb-6">
              Are you sure you want to permanently delete{" "}
              <span className="font-medium text-blue-600 dark:text-blue-400">
                {supplierToDelete.supplierName}
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
                onClick={() => {
                  handleDelete(supplierToDelete.supplierId);
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
