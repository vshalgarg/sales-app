"use client";
import { useState, useRef, useEffect } from "react";
import { Ellipsis, Pencil, Trash2, ArrowLeft, ArrowRight } from "lucide-react";
import TransportService from "../service/TransportService";
import AddNewTransport from "./AddNewTransport";
import { useSnackbar } from "../context/SnackbarContext";
import UniversalSearch from "../components/UniversalSearch";

export default function TransportDashboard() {
  const [loading, setLoading] = useState(false);
  const [isSearchActive, setIsSearchActive] = useState(false);

  const [open, setOpen] = useState(false);
  const [editingTransport, setEditingTransport] = useState(null);

  const [transports, setTransports] = useState([]);
  const [query, setQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const rowsPerPage = 6;
  const [openMenuIndex, setOpenMenuIndex] = useState(null);
  const dropdownRef = useRef(null);
  const { showSnackbar } = useSnackbar();

  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [transportToDelete, setTransportToDelete] = useState(null);

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
    if (!isSearchActive) fetchTransports(currentPage);
  }, [currentPage, isSearchActive]);

  const fetchTransports = async (page = 1) => {
    setLoading(true);
    try {
      const data = await TransportService.getTransports(page, rowsPerPage);
      setTransports(data.content || []);
      setTotalPages(data.totalPages || 1);
    } catch (error) {
      console.error("Error fetching transports:", error);
      setTransports([]);
      setTotalPages(1);
      showSnackbar("Failed to load transports.", "error");
    } finally {
      setLoading(false);
    }
  };

  const confirmDelete = (transport) => {
    setTransportToDelete(transport);
    setDeleteModalOpen(true);
    setOpenMenuIndex(null);
  };

  const handleDelete = async () => {
    if (!transportToDelete) return;
    try {
      const result = await TransportService.deleteTransport(transportToDelete.id);
      showSnackbar(result.message || "Transport deleted successfully", "success");
      fetchTransports(currentPage);
    } catch (error) {
      console.error("Error deleting transport:", error);
      showSnackbar("Failed to delete transport.", "error");
    } finally {
      setDeleteModalOpen(false);
      setTransportToDelete(null);
    }
  };

  const searchFn = async (query) => {
    return await TransportService.searchTransports(query);
  };

  const handleEdit = (transport) => {
    setEditingTransport(transport);
    setOpen(true);
    setOpenMenuIndex(null);
  };

  const handleAddNew = () => {
    setEditingTransport(null);
    setOpen(true);
  };

  const handleChangePage = (page) => {
    setCurrentPage(page);
  };

  const handleModalClose = () => {
    setOpen(false);
    setEditingTransport(null);
  };

  const handleSuccess = () => {
    fetchTransports(currentPage);
    handleModalClose();
  };

  return (
    <div className="text-gray-900 dark:text-gray-100">
      {/* Header */}
      <div className="flex justify-between items-center mb-6 h-[8vh]">
        <h2 className="text-2xl font-bold">Transport Overview</h2>
        <button
          onClick={handleAddNew}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700"
        >
          Add New Transport
        </button>
      </div>

      <UniversalSearch
        placeholder="Search transports..."
        query={query}
        setQuery={setQuery}
        searchFn={TransportService.searchTransports}
        onResult={(results) => {
          setTransports(results);
          setIsSearchActive(results.length > 0 && query.trim() !== "");
        }}
      />

      {/* Table */}
      <div className="relative mt-6 rounded-lg shadow bg-white dark:bg-gray-900">
        <table className="min-w-full table-fixed text-sm text-left">
          <thead className="bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 uppercase text-xs">
            <tr>
              <th className="px-6 py-3 w-24">ID</th>
              <th className="px-6 py-3 w-80">Name</th>
              <th className="px-6 py-3 w-32">Status</th>
              <th className="px-6 py-3 w-32">Actions</th>
            </tr>
          </thead>
          <tbody>
            {transports.length > 0 ? (
              transports.map((t, i) => (
                <tr
                  key={t.id || i}
                  className="border-t border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800"
                >
                  <td className="px-6 py-2">{t.id}</td>
                  <td className="px-6 py-2 font">{t.name}</td>
                  <td className="px-6 py-2">
                    <span
                      className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${t.isActive
                          ? "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400"
                          : "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400"
                        }`}
                    >
                      {t.isActive ? "Active" : "Inactive"}
                    </span>
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
                        className="absolute right-14 bg-white dark:bg-gray-800 border dark:border-gray-700 rounded shadow-md z-10 w-32"
                      >
                        <button
                          onClick={() => handleEdit(t)}
                          className="flex items-center gap-2 w-full text-left px-4 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700"
                        >
                          <Pencil className="w-4 h-4" />
                          Edit
                        </button>
                        <button
                          onClick={() => confirmDelete(t)}
                          className="flex items-center gap-2 w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100 dark:hover:bg-gray-700"
                        >
                          <Trash2 className="w-4 h-4" />
                          Delete
                        </button>
                      </div>
                    )}
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="4" className="text-center text-gray-500 dark:text-gray-400 py-8">
                  {loading ? "Loading..." : "No Transports Found"}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPages > 1 && !isSearchActive && (
        <div className="flex justify-center mt-6">
          <div className="flex items-center space-x-2">
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

            <div className="flex space-x-1">
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

      {/* Add / Edit Transport Modal */}
      {open && (
        <AddNewTransport
          open={open}
          setOpen={handleModalClose}
          editingTransport={editingTransport}
          onSuccess={handleSuccess}
        />
      )}

      {/* Delete Confirmation Modal */}
      {deleteModalOpen && transportToDelete && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50">
          <div className="bg-white dark:bg-zinc-900 rounded-2xl shadow-2xl w-[380px] p-6">
            <div className="flex items-center justify-center mb-4">
              <div className="bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 rounded-full p-3">
                <Trash2 className="h-8 w-8" />
              </div>
            </div>

            <h3 className="text-lg font-semibold text-center text-gray-800 dark:text-gray-100 mb-2">
              Delete Transport
            </h3>

            <p className="text-center text-gray-600 dark:text-gray-400 text-sm mb-6">
              Are you sure you want to permanently delete{" "}
              <span className="font-medium text-blue-600 dark:text-blue-400">
                {transportToDelete.name}
              </span>
              ? This action cannot be undone.
            </p>

            <div className="flex justify-center gap-3">
              <button
                onClick={() => setDeleteModalOpen(false)}
                className="px-4 py-2 rounded-lg border border-gray-300 dark:border-zinc-700 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-zinc-800 transition-all"
              >
                Cancel
              </button>
              <button
                onClick={handleDelete}
                className="px-4 py-2 rounded-lg bg-red-600 text-white hover:bg-red-700 shadow-sm transition-all"
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