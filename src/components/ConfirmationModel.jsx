import React from 'react';
import AppButton from "../components/common/AppButton"
const ConfirmationModal = ({
  isOpen,
  onClose,
  onConfirm,
  title = "Confirm Action",
  message = "Are you sure you want to proceed?",
  confirmText = "Confirm",
  cancelText = "Cancel",
  confirmButtonColor = "blue",
  loading = false,
}) => {
  if (!isOpen) return null;

  const colorMap = {
    blue: "bg-blue-600 hover:bg-blue-700",
    red: "bg-red-600 hover:bg-red-700",
    green: "bg-green-600 hover:bg-green-700",
  };

  const btnClass = colorMap[confirmButtonColor] || colorMap.blue;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/60"
        onClick={onClose}
        aria-hidden="true"
      />

      {/* Modal Card */}
      <div className="relative w-full max-w-md bg-white rounded-xl shadow-2xl overflow-hidden">
        {/* Header */}
        <div className="px-6 py-5 border-b border-gray-200 flex items-center justify-between">
          <h3 className="text-xl font-semibold text-gray-900">{title}</h3>
          <button
            type="button"
            onClick={onClose}
            disabled={loading}
            className="text-gray-500 hover:text-gray-700 text-2xl leading-none"
            aria-label="Close"
          >
            ×
          </button>
        </div>

        {/* Body */}
        <div className="px-6 py-6">
          <p className="text-gray-600 text-base">{message}</p>
        </div>

        {/* Footer */}
        <div className="px-6 py-5 border-t border-gray-200 flex justify-end gap-4">
          <AppButton
            type="cancel"
            onClick={onClose}
            disabled={loading}
            // className="px-5 py-2.5 bg-gray-400 text-gray-800 rounded-lg hover:bg-gray-300 disabled:opacity-60 transition-colors"
          >
            {cancelText}
          </AppButton>

          <AppButton
            type="primary"
            onClick={onConfirm}
            disabled={loading}
            // className={`px-5 py-2.5 text-white rounded-lg font-medium transition-colors disabled:opacity-60 ${btnClass}`}
          >
            {loading ? "Processing..." : confirmText}
          </AppButton>
        </div>
      </div>
    </div>
  );
};

export default ConfirmationModal;