import { Ellipsis, Eye, Pencil } from "lucide-react";
import { useEffect, useState } from "react";
import CreditDetail from "../modals/CreditDetail";

const CreditHistory = ({ initialCreditHistory, creditFiltersApplied }) => {
  const [openMenuIndex, setOpenMenuIndex] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedCreditDetail, setSelectedCreditDetail] = useState(null);
  const [creditHistory, setCreditHistory] = useState(
    initialCreditHistory || []
  );

  useEffect(() => {
    // This is crucial: update the internal state whenever the list from the filter component changes
    setCreditHistory(initialCreditHistory || []);
  }, [initialCreditHistory]);

  const handleEllipsisClick = (i) => {
    setOpenMenuIndex((prevIndex) => (prevIndex === i ? null : i));
  };

  return (
    <>
      <div className="relative mt-6 rounded-lg shadow bg-white dark-bg-gray-900">
        <table className="min-w-full table-auto text-sm text-left">
          <thead className="bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 uppercase text-xs">
            <tr>
              <th className="px-6 py-3">Bill Number</th>
              <th className="px-6 py-3">Date</th>
              <th className="px-6 py-3">Payment Type</th>
              <th className="px-6 py-3">Supplier</th>
              <th className="px-6 py-3">Customer</th>
              <th className="px-6 py-3">Reference Number</th>
              <th className="px-6 py-3">Received Amount</th>
              <th className="px-6 py-3">Actions</th>
            </tr>
          </thead>
          <tbody>
            {creditHistory.length > 0 ? (
              creditHistory.map((h, i) => (
                <tr
                  key={i}
                  className="border-t border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800"
                >
                  <td className="px-6 py-2">{h.billNumber}</td>
                  <td className="px-6 py-2">{h.date}</td>
                  <td className="px-6 py-2">{h.paymentType}</td>
                  <td className="px-6 py-2">{h.supplierName}</td>
                  <td className="px-6 py-2">{h.customerName}</td>
                  <td className="px-6 py-2">{h.referenceNumber}</td>
                  <td className="px-6 py-2">{h.receivedAmount}</td>
                  <td className="px-6 py-2 relative">
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
                        {/* <button
                          onClick={() => {
                            setOpen(true);
                            setSelectedBillDetail(h);
                            setOpenMenuIndex(null);
                          }}
                          className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-300 dark:hover:bg-gray-700"
                        >
                          <Pencil className="w-5 h-5" />
                        </button> */}
                      </div>
                    )}
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td
                  colSpan="8"
                  className="text-center text-gray-500 dark:text-gray-400 py-4"
                >
                  {creditFiltersApplied
                    ? "No data found"
                    : "Apply filters to view credit history"}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {isModalOpen && selectedCreditDetail && (
        <CreditDetail
          selectedCreditDetail={selectedCreditDetail}
          setIsModalOpen={setIsModalOpen}
        />
      )}

      {/*open && selectedBillDetail && (
        <EditBillDetail
          open={open}
          selectedBillDetail={selectedBillDetail}
          setOpen={setOpen}
        />
      )} */}
    </>
  );
};

export default CreditHistory;
