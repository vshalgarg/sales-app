
import { useState, useRef, useEffect, useCallback } from "react";
import { Ellipsis, Pencil, Trash2 } from "lucide-react";
import TransportService from "../service/TransportService";
import AddNewTransport from "./AddNewTransport";
import { useSnackbar } from "../context/SnackbarContext";
import UniversalSearch from "../components/UniversalSearch";
import PaginationComponent from "./PaginationComponenet"

export default function TransportDashboard() {
  const [loading, setLoading] = useState(false);
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [open, setOpen] = useState(false);
  const [editingTransport, setEditingTransport] = useState(null);
  const [transports, setTransports] = useState([]);
  const [query, setQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);
  const rowsPerPage = 10;
  const [openMenuIndex, setOpenMenuIndex] = useState(null);
  const [totalItems, setTotalItems] = useState(0);
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

  const fetchTransports = useCallback(async (uiPage = 1) => {
    const backendPage = uiPage - 1;
    setLoading(true);
    try {
      const data = await TransportService.getTransports(backendPage, rowsPerPage);
      setTransports(data.content || []);
      setTotalPages(data.totalPages || 0);
      setTotalItems(data.totalElements || 0);
      setCurrentPage(uiPage);
    } catch (error) {
      console.error("Error fetching transports:", error);
      setTransports([]);
      setTotalPages(0);
      setTotalItems(0);
      showSnackbar("Failed to load transports.", "error");
    } finally {
      setLoading(false);
    }
  }, [rowsPerPage, showSnackbar]);

  const handleSearchResult = (response, searchQuery) => {
console.log("REQUEST on search", searchQuery, 
          )
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
    setCurrentPage(1);
  };

  const handleChangePage = async (newPage) => {
    if (newPage < 1 || (totalPages > 0 && newPage > totalPages)) return;
    
    setCurrentPage(newPage);
    
    if (isSearchActive && query.trim()) {
      try {
        const backendPage = newPage - 1;
        console.log("REQUEST", query, 
          backendPage, 
          rowsPerPage)
        const response = await TransportService.searchTransports(
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
    console.log(query,"Query")
  }, [query, isSearchActive, handleClearSearch]);

  useEffect(() => {
    fetchTransports(1);
  }, [fetchTransports]);

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
      
      if (isSearchActive && query.trim()) {
        const backendPage = currentPage - 1;
        const response = await TransportService.searchTransports(
          query, 
          backendPage, 
          rowsPerPage
        );
        
        handleSearchResult(response, query);
      } else {
        fetchTransports(currentPage);
      }
    } catch (error) {
      console.error("Error deleting transport:", error);
      showSnackbar("Failed to delete transport.", "error");
    } finally {
      setDeleteModalOpen(false);
      setTransportToDelete(null);
    }
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

      {/* Search */}
      <div className="flex items-center gap-2 mb-6">
        <UniversalSearch
          placeholder="Search transports..."
          query={query}
          setQuery={setQuery}
          searchFn={TransportService.searchTransports}
          onResult={handleSearchResult}
          onClear={handleClearSearch}
          suggestionKey="name"
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
            {loading ? (
              <tr>
                <td colSpan="4" className="text-center py-8">
                  <div className="flex justify-center">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                  </div>
                </td>
              </tr>
            ) : transports.length > 0 ? (
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
                  No Transports Found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination*/}
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