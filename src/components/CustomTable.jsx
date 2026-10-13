import { Eye, Pencil } from "lucide-react";

const CustomTable = ({ columns = [], data = [], emptyMessage = "No records found" }) => {
  return (
    <div className="w-full overflow-x-auto">
      <table className="w-full text-sm text-left">
        <thead className="bg-gray-50 text-gray-600 border-b">
          <tr>
            {columns.map((column) => (
              <th
                key={column.accessor || column.header}
                className="px-4 py-3 font-semibold whitespace-nowrap"
              >
                {column.header}
              </th>
            ))}
          </tr>
        </thead>

        <tbody className="divide-y divide-gray-100">
          {data.length > 0 ? (
            data.map((row, rowIndex) => (
              <tr
                key={row.id ?? rowIndex}
                className="hover:bg-gray-50 transition-colors"
              >
                {columns.map((column) => (
                  <td
                    key={column.accessor || column.header}
                    className="px-4 py-3 text-gray-700"
                  >
                    {column.isAction ? (
                      <div className="flex items-center gap-2">
                        {(column.actions?.(row) || []).map(
                          (action) => {
                            const Icon = action.label === "View" ? Eye : action.label === "Edit" ? Pencil : null;

                            return (
                              <button
                                key={action.label}
                                type="button"
                                onClick={action.onClick}
                                title={action.label}
                                className="inline-flex items-center gap-1
                                  rounded-md border border-gray-200
                                  px-3 py-1.5 text-xs font-medium
                                  hover:bg-gray-100"
                              >
                                {Icon && <Icon size={14} />}
                                {action.label}
                              </button>
                            );
                          },
                        )}
                      </div>
                    ) : column.Cell ? (
                      <column.Cell
                        value={row[column.accessor]}
                        row={row}
                      />
                    ) : (
                      row[column.accessor] ?? "-"
                    )}
                  </td>
                ))}
              </tr>
            ))
          ) : (
            <tr>
              <td
                colSpan={columns.length || 1}
                className="px-4 py-10 text-center text-gray-500"
              >
                {emptyMessage}
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
};

export default CustomTable;