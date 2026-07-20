import { Trash2 } from "lucide-react";
import AppButton from "./AppButton";
import { PAGE_TITLE_CLASS } from "../../theme/appTheme";

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
      <div className="relative w-full max-w-sm sm:max-w-md overflow-visible bg-white rounded-2xl shadow-2xl px-5 pt-10 pb-6 sm:px-6 sm:pt-7 sm:pb-7">
        <div className="absolute left-1/2 top-0 -translate-x-1/2 -translate-y-1/2 flex h-12 w-12 items-center justify-center rounded-full border border-brand-surface-border bg-violet-100">
          <Trash2 className="h-5 w-5 text-violet-600" />
        </div>

        <h3 className={`${PAGE_TITLE_CLASS} text-center  mb-4`}>{title}</h3>

        <div className="text-sm sm:text-base text-gray-600 text-center mb-4">
          {message}
        </div>

        <div className="flex flex-col-reverse sm:flex-row sm:justify-end gap-3">
          <AppButton type="cancel" fullWidth onClick={onClose}>
            {cancelText}
          </AppButton>

          <AppButton type="primary" fullWidth onClick={onConfirm}>
            {confirmText}
          </AppButton>
        </div>
      </div>
    </div>
  );
};

export default DeleteConfirmModal;
