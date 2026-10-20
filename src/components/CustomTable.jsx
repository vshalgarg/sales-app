import { Eye, Pencil, Trash2 } from "lucide-react";

const CustomTable = ({ columns = [], data = [], emptyMessage = "No records found" }) => {
  return (
    <div className="w-full max-w-full min-w-0 overflow-hidden rounded-lg border border-gray-200">
      <div className="w-full overflow-x-auto">
        <table className="w-full min-w-[600px] table-auto border-collapse text-left text-sm">
          <thead className="border-b border-gray-200 bg-gray-50 text-gray-600">
            <tr>
              {columns.map((column) => (
                <th
                  key={column.accessor || column.header}
                  className={`whitespace-nowrap px-4 py-3 font-semibold ${
                    column.isAction ? "text-center" : "text-left"
                  }`}
                  style={{
                    width:
                      column.width ||
                      (column.isAction ? "30%" : "35%"),
                  }}
                >
                  {column.header}
                </th>
              ))}
            </tr>
          </thead>

          <tbody className="divide-y divide-gray-100 bg-white">
            {data.length > 0 ? (
              data.map((row, rowIndex) => (
                <tr
                  key={row.id ?? rowIndex}
                  className="transition-colors hover:bg-gray-50"
                >
                  {columns.map((column) => (
                    <td
                      key={column.accessor || column.header}
                      className={`px-4 py-3 text-gray-700 ${
                        column.isAction ? "text-center" : "text-left"
                      }`}
                    >
                      {column.isAction ? (
                        <div className="flex flex-nowrap items-center justify-center gap-2">
                          {(column.actions?.(row) || []).map((action) => {
                            const Icon =
                              action.label === "View"
                                ? Eye
                                : action.label === "Edit"
                                  ? Pencil
                                  : action.label === "Delete"
                                    ? Trash2
                                    : null;

                            return (
                              <button
                                key={action.label}
                                type="button"
                                onClick={action.onClick}
                                title={action.label}
                                aria-label={action.label}
                                className="inline-flex shrink-0 items-center justify-center gap-1 rounded-md border border-gray-200 bg-white px-3 py-1.5 text-sm font-medium text-gray-700 transition-colors hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                              >
                                {Icon && <Icon size={14} />}
                                <span>{action.label}</span>
                              </button>
                            );
                          })}
                        </div>
                      ) : column.Cell ? (
                        <div className="min-w-0 break-words">
                          <column.Cell
                            value={row[column.accessor]}
                            row={row}
                          />
                        </div>
                      ) : (
                        <span className="break-words">
                          {row[column.accessor] ?? "-"}
                        </span>
                      )}
                    </td>
                  ))}
                </tr>
              ))
            ) : (
              <tr>
                <td
                  colSpan={columns.length || 1}
                  className="px-4 py-8 text-center text-gray-500"
                >
                  {emptyMessage}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default CustomTable;