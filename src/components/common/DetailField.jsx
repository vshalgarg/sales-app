import { DETAIL_FIELD_VALUE_CLASS } from "../../theme/cardTheme";

const DetailField = ({ label, children, valueClassName = "" }) => (
  <div>
    <label className="block text-sm font-medium mb-1 text-gray-700 dark:text-gray-300">
      {label}
    </label>
    <div
      className={`rounded px-3 py-2 text-sm min-h-9 break-words border ${DETAIL_FIELD_VALUE_CLASS} ${valueClassName}`}
    >
      {children}
    </div>
  </div>
);

export default DetailField;
