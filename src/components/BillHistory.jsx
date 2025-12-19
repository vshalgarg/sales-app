import { Ellipsis, Eye, Pencil } from "lucide-react";
import { useEffect, useState } from "react";
import BillDetail from "../modals/BillDetail";
import EditBillDetail from "../modals/EditBillDetail";

const BillHistory = ({ initialBillHistory, billFiltersApplied,onBillUpdated}) => {
  const [openMenuIndex, setOpenMenuIndex] = useState(null);
  const [billHistory, setBillHistory] = useState(initialBillHistory || []);
  const [isModalOpen, setIsModalOpen] = useState(
    JSON.parse(localStorage.getItem("isModalOpen")) || false
  );
  const [open, setOpen] = useState(
    JSON.parse(localStorage.getItem("isEditModalOpen")) || false
  );

  const [selectedBillDetail, setSelectedBillDetail] = useState(
    JSON.parse(localStorage.getItem("selectedBillDetail")) || null
  );

  const handleEllipsisClick = (i) => {
    setOpenMenuIndex((prevIndex) => (prevIndex === i ? null : i));
  };

  // Close dropdown on outside click
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (
        !event.target.closest(".dropdown-menu") &&
        !event.target.closest(".ellipsis-btn")
      ) {
        setOpenMenuIndex(null);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  useEffect(() => {
    // This is crucial: update the internal state whenever the list from the filter component changes
    setBillHistory(initialBillHistory || []);
  }, [initialBillHistory]);

  // const fetchBillHistory = async () => {
  //   // Only fetch if initialBillHistory is not provided (useful if this component is used standalone)
  //   if (!initialBillHistory) {
  //     const response = await getBillHistory();
  //     setBillHistory(response);
  //   }
  // };

  // 🔹 Sync modal states to localStorage
  useEffect(() => {
    localStorage.setItem("isModalOpen", JSON.stringify(isModalOpen));
  }, [isModalOpen]);

  useEffect(() => {
    localStorage.setItem("isEditModalOpen", JSON.stringify(open));
  }, [open]);

  useEffect(() => {
    if (selectedBillDetail) {
      localStorage.setItem(
        "selectedBillDetail",
        JSON.stringify(selectedBillDetail)
      );
    } else {
      localStorage.removeItem("selectedBillDetail");
    }
  }, [selectedBillDetail]);

  return (
    <>
      <div className="relative mt-6 rounded-lg shadow bg-white dark-bg-gray-900">
        <table className="min-w-full table-auto text-sm text-left">
          <thead className="bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 uppercase text-xs">
            <tr>
              <th className="px-6 py-3">Bill Number</th>
              <th className="px-6 py-3">Date</th>
              <th className="px-6 py-3">Received Date</th>
              <th className="px-6 py-3">Order</th>
              <th className="px-6 py-3">Supplier</th>
              <th className="px-6 py-3">Customer</th>
              <th className="px-6 py-3">Bill Amount</th>
              <th className="px-6 py-3">Actions</th>
            </tr>
          </thead>
          <tbody>
            {billHistory.length > 0 ? (
              billHistory.map((h, i) => (
                <tr
                  key={i}
                  className="border-t border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800"
                >
                  <td className="px-6 py-2">{h.billNumber}</td>
                  <td className="px-6 py-2">{h.date}</td>
                  <td className="px-6 py-2">{h.receivedDate}</td>
                  <td className="px-6 py-2">{h.order}</td>
                  <td className="px-6 py-2">{h.supplierName}</td>
                  <td className="px-6 py-2">{h.customerName}</td>
                  <td className="px-6 py-2">{h.billAmount}</td>
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
                            setSelectedBillDetail(h);
                            setOpenMenuIndex(null);
                          }}
                          className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-300 dark:hover:bg-gray-700"
                        >
                          <Eye className="w-5 h-5 text-gray-600 dark:text-gray-300" />
                        </button>
                        <button
                          onClick={() => {
                            setOpen(true);
                            setSelectedBillDetail(h);
                            setOpenMenuIndex(null);
                          }}
                          className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-300 dark:hover:bg-gray-700"
                        >
                          <Pencil className="w-5 h-5" />
                        </button>
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
                  {billFiltersApplied
                    ? "No data found"
                    : "Apply filters to view credit history"}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {isModalOpen && selectedBillDetail && (
        <BillDetail
          selectedBillDetail={selectedBillDetail}
          setIsModalOpen={setIsModalOpen}
        />
      )}

      {open && selectedBillDetail && (
        <EditBillDetail
          open={open}
          selectedBillDetail={selectedBillDetail}
          setOpen={setOpen}
          onUpdateSuccess={onBillUpdated}
        />
      )}
    </>
  );
};

export default BillHistory;
