import { AlertTriangle } from "lucide-react";
import AppButton from "./AppButton";
import { PAGE_TITLE_CLASS } from "../../theme/appTheme";

export default function ConfirmDialog({
  open,
  title = "Unsaved Changes",
  message = "You have unsaved changes. Are you sure you want to leave?",
  onConfirm,
  onCancel,
}) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-4">
      <div className="relative w-full max-w-sm sm:max-w-md overflow-visible bg-white rounded-2xl shadow-2xl px-5 pt-10 pb-6 sm:px-6 sm:pt-12 sm:pb-7">
        <div className="absolute left-1/2 top-0 -translate-x-1/2 -translate-y-1/2 flex h-12 w-12 items-center justify-center rounded-full border border-brand-surface-border bg-violet-100">
          <AlertTriangle className="h-5 w-5 text-violet-600" />
        </div>

        <h3 className={`${PAGE_TITLE_CLASS} text-center mt-2 mb-3`}>
          {title}
        </h3>

        <div className="text-sm sm:text-base text-gray-600 text-center mb-8">
          {message}
        </div>

        <div className="flex flex-col-reverse sm:flex-row sm:justify-end gap-3">
          <AppButton type="cancel" fullWidth onClick={onCancel}>
            Stay
          </AppButton>
          <AppButton type="primary" fullWidth onClick={onConfirm}>
            Leave
          </AppButton>
        </div>
      </div>
    </div>
  );
}
