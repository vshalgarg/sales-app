import { useEffect, useState } from "react";

const PurchaseHistory = ({ initialPurchaseHistory, filtersApplied }) => {
  const [selectedPurchaseDetail, setSelectedPurchaseDetail] = useState(null);
  const [purchaseHistory, setPurchaseHistory] = useState(
    initialPurchaseHistory || []
  );

  useEffect(() => {
    // This is crucial: update the internal state whenever the list from the filter component changes
    setPurchaseHistory(initialPurchaseHistory || []);
  }, [initialPurchaseHistory]);
  return (
    <>
      <div className="relative mt-6 rounded-lg shadow bg-white dark-bg-gray-900">
        <table className="min-w-full table-auto text-sm text-left">
          <thead className="bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 uppercase text-xs">
            <tr>
              <th className="px-6 py-3">Purchase Id</th>
              <th className="px-6 py-3">Date</th>
              <th className="px-6 py-3">Staff Name</th>
              <th className="px-6 py-3">Supplier Name</th>
              <th className="px-6 py-3">Customer Name</th>
              <th className="px-6 py-3">Purchase Amount</th>
            </tr>
          </thead>
          <tbody>
            {purchaseHistory.length > 0 ? (
              purchaseHistory.map((h, i) => (
                <tr
                  key={i}
                  className="border-t border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800"
                >
                  <td className="px-6 py-2">{h.id}</td>
                  <td className="px-6 py-2">{h.date}</td>
                  <td className="px-6 py-2">{h.staffName}</td>
                  <td className="px-6 py-2">{h.supplierName}</td>
                  <td className="px-6 py-2">{h.customerName}</td>
                  <td className="px-6 py-2">{h.purchaseAmount}</td>
                  {/* <td className="px-6 py-2 relative">
                    <button
                      onClick={() => handleEllipsisClick(i)}
                      className="ellipsis-btn text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
                    >
                      <Ellipsis />
                    </button>

                    {openMenuIndex === i && (
                      <div className="dropdown-menu absolute bg-white dark:bg-gray-800 border dark:border-gray-700 rounded shadow-md mt-1 z-10 w-22">
                        <button
                          onClick={() => {
                            setIsModalOpen(true);
                            setSelectedCreditDetail(h);
                            setOpenMenuIndex(null);
                          }}
                          className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-300 dark:hover:bg-gray-700"
                        >
                          <Eye className="w-5 h-5 text-gray-600 dark:text-gray-300" />
                        </button>
                        <button
                          // onClick={() => {
                          //   setOpen(true);
                          //   setSelectedBillDetail(h);
                          //   setOpenMenuIndex(null);
                          // }}
                          className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-300 dark:hover:bg-gray-700"
                        >
                          <Pencil className="w-5 h-5" />
                        </button>
                      </div>
                    )}
                  </td> */}
                </tr>
              ))
            ) : (
              <tr>
                <td
                  colSpan="8"
                  className="text-center text-gray-500 dark:text-gray-400 py-4"
                >
                  {filtersApplied
                    ? "No data found"
                    : "Apply filters to view purchase history"}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </>
  );
};

export default PurchaseHistory;
