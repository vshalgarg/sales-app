export default function SmartTable({
  columns = [],
  data = [],
  loading = false,
  onView,
  onDelete,
  dropdownRef,
  openMenuIndex,
  setOpenMenuIndex,
}) {
  return (
    <div className="relative rounded-lg shadow bg-white mt-6">
      <table className="min-w-full table-auto text-sm text-left">
        <thead className="bg-gray-100 text-gray-700 uppercase text-xs">
          <tr>
            {columns.map((col, index) => (
              <th key={index} className="px-6 py-4">{col.label}</th>
            ))}
            <th className="px-6 py-4">Actions</th>
          </tr>
        </thead>
         
        <tbody>
          {loading ? (
            <tr>
              <td colSpan={columns.length + 1} className="text-center py-4">
                Loading...
              </td>
            </tr>
          ) : data.length > 0 ? (
            data.map((row, i) => (
              <tr key={i} className="border-t hover:bg-gray-50">
                {columns.map((col, idx) => (
                  <td key={idx} className="px-6 py-1">
                    {typeof col.accessor === "function"
                      ? col.accessor(row)
                      : row[col.accessor] ?? "-"}
                  </td>
                ))}

                <td className="px-6 py-2 relative">
                  <button
                    onClick={() =>
                      setOpenMenuIndex(openMenuIndex === i ? null : i)
                    }
                    className="text-gray-600 hover:text-gray-900"
                  >
                    ⋮
                  </button>

                  {openMenuIndex === i && (
                    <div
                      ref={dropdownRef}
                      className="absolute bg-white border rounded shadow-md mt-1 z-10 w-22"
                    >
                      <button
                        onClick={() => {
                          setOpenMenuIndex(null);
                          onView(row);
                        }}
                        className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-100"
                      >
                        👁 View
                      </button>

                      <button
                        onClick={() => {
                          setOpenMenuIndex(null);
                          onDelete(row);
                        }}
                        className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-100 text-red-600"
                      >
                        🗑 Delete
                      </button>
                    </div>
                  )}
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td
                colSpan={columns.length + 1}
                className="text-center py-4 text-gray-500"
              >
                No Records Found
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
