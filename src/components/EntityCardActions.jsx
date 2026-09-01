import { Eye, Pencil, Copy, Trash2 } from "lucide-react";
import {
  CARD_ACTION_BORDER_CLASS,
  CARD_ACTION_DIVIDER_CLASS,
} from "../theme/cardTheme";

const actionButtonClass = `flex flex-1 items-center justify-center rounded-lg border ${CARD_ACTION_BORDER_CLASS} bg-white dark:bg-zinc-800 p-2.5 transition-colors hover:bg-gray-50 dark:hover:bg-zinc-700 disabled:opacity-50 disabled:cursor-not-allowed`;

const getActionGridClass = (count) => {
  if (count <= 2) return "grid-cols-2";
  if (count === 3) return "grid-cols-3";
  return "grid-cols-4";
};

const EntityCardActions = ({ onView, onEdit, onCopy, onDelete }) => {
  const actionCount = [onView, onEdit, onCopy, onDelete].filter(Boolean).length;
  if (!actionCount) return null;

  return (
  <div className={`mt-3 grid ${getActionGridClass(actionCount)} gap-2 pt-3 ${CARD_ACTION_DIVIDER_CLASS}`}>
    {onView && (
      <button
        type="button"
        className={actionButtonClass}
        onClick={onView}
        aria-label="View details"
      >
        <Eye className="h-4 w-4 text-blue-700 dark:text-blue-400" />
      </button>
    )}
    {onEdit && (
      <button
        type="button"
        className={actionButtonClass}
        onClick={onEdit}
        aria-label="Edit"
      >
        <Pencil className="h-4 w-4 text-blue-700 dark:text-blue-400" />
      </button>
    )}
    {onCopy && (
      <button
        type="button"
        className={actionButtonClass}
        onClick={onCopy}
        aria-label="Copy details"
      >
        <Copy className="h-4 w-4 text-blue-700 dark:text-blue-400" />
      </button>
    )}
    {onDelete && (
      <button
        type="button"
        className={actionButtonClass}
        onClick={onDelete}
        aria-label="Delete"
      >
        <Trash2 className="h-4 w-4 text-red-600 dark:text-red-400" />
      </button>
    )}
  </div>
  );
};

export default EntityCardActions;
