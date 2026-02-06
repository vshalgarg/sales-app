const DeleteConfirmModal = ({
  open,
  title = "Delete",
  message,
  confirmText = "Delete",
  cancelText = "Cancel",
  onConfirm,
  onClose,
}) => {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-4">
      <div className="w-full max-w-sm sm:max-w-md bg-white rounded-2xl shadow-2xl p-5 sm:p-6">
        {/* Title */}
        <h3 className="text-base sm:text-lg font-semibold text-gray-800 mb-2">
          {title}
        </h3>

        {/* Message */}
        <div className="text-sm sm:text-base text-gray-600 mb-6">
          {message}
        </div>

        {/* Actions */}
        <div className="flex flex-col-reverse sm:flex-row sm:justify-end gap-3">
          <button
            onClick={onClose}
            className="w-full sm:w-auto px-4 py-2.5 border rounded-lg text-gray-700 hover:bg-gray-100 transition"
          >
            {cancelText}
          </button>

          <button
            onClick={onConfirm}
            className="w-full sm:w-auto px-4 py-2.5 rounded-lg bg-red-600 text-white hover:bg-red-700 transition"
          >
            {confirmText}
          </button>
        </div>
      </div>
    </div>
  );
};

export default DeleteConfirmModal;
