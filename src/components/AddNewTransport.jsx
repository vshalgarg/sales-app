"use client";
import { useState, useEffect } from "react";
import { X } from "lucide-react";
import TransportService from "../service/TransportService";
import { useSnackbar } from "../context/SnackbarContext";

export default function AddNewTransport({
  open,
  setOpen,
  editingTransport = null,
  onSuccess,
}) {
  const { showSnackbar } = useSnackbar();

  const [formData, setFormData] = useState({
    name: "",
    isActive: true,
  });

  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (editingTransport) {
      setFormData({
        name: editingTransport.name || "",
        isActive: editingTransport.isActive ?? true,
      });
    } else {
      setFormData({
        name: "",
        isActive: true,
      });
    }
  }, [editingTransport, open]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

 const handleSubmit = async (e) => {
  e.preventDefault();

  if (!formData.name.trim()) {
    showSnackbar("Transport name is required.", "error");
    return;
  }

  setLoading(true);

  try {
    let response;

    if (editingTransport) {
      // UPDATE CASE
      const updateRequest = {
        id: editingTransport.id,
        name: formData.name.trim(),
        isActive: formData.isActive, 
      };

      response = await TransportService.updateTransport(updateRequest);
    } else {
      // CREATE CASE
      const createRequest = {
        name: formData.name.trim(),
        isActive: true, // new transports are active by default
      };

      response = await TransportService.createTransport(createRequest);
    }

    if (response.success) {
      showSnackbar(response.message || "Transport saved successfully!", "success");
    } else {
      showSnackbar(response.message || "Operation failed.", "error");
      return;
    }
    onSuccess();

  } catch (error) {
    console.error("Error saving transport:", error);
    const msg =
      error.response?.data?.message ||
      error.response?.data?.error ||
      error.message ||
      "Failed to save transport. Please try again.";

    showSnackbar(msg, "error");
  } finally {
    setLoading(false);
  }
};

  const handleClose = () => {
    if (!loading) {
      setOpen(false);
    }
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50">
      <div className="bg-white dark:bg-zinc-900 rounded-2xl shadow-2xl w-[420px] p-6 relative">
        {/* Close Button */}
        <button
          onClick={handleClose}
          disabled={loading}
          className="absolute top-4 right-4 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
        >
          <X size={24} />
        </button>

        {/* Title */}
        <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-6 text-center">
          {editingTransport ? "Edit Transport" : "Add New Transport"}
        </h2>

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-5">
          {/* Name Field */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Transport Name <span className="text-red-500">*</span>
            </label>
            <input
              type="text"
              name="name"
              value={formData.name}
              onChange={handleChange}
              disabled={loading}
              className="w-full px-4 py-2 border border-gray-300 dark:border-zinc-700 rounded-lg bg-white dark:bg-zinc-800 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
              placeholder="Enter transport name"
              required
            />
          </div>

          {/* Active Status (only show in edit mode or if you want control) */}
          {editingTransport && (
            <div className="flex items-center gap-3">
              <input
                type="checkbox"
                id="isActive"
                name="isActive"
                checked={formData.isActive}
                onChange={handleChange}
                disabled={loading}
                className="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
              />
              <label htmlFor="isActive" className="text-sm font-medium text-gray-700 dark:text-gray-300">
                Active
              </label>
            </div>
          )}

          {/* Buttons */}
          <div className="flex justify-end gap-3 pt-4">
            <button
              type="button"
              onClick={handleClose}
              disabled={loading}
              className="px-5 py-2 rounded-lg border border-gray-300 dark:border-zinc-700 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-zinc-800 transition"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-5 py-2 rounded-lg bg-blue-600 text-white hover:bg-blue-700 shadow-sm transition disabled:opacity-70 disabled:cursor-not-allowed flex items-center gap-2"
            >
              {loading ? (
                <>Saving...</>
              ) : (
                <>{editingTransport ? "Update" : "Add"} Transport</>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}