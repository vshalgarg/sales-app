const CreditDetail = ({ selectedCreditDetail, setIsModalOpen }) => {
  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-80 z-50">
      <div className="bg-white dark:bg-gray-900 w-full max-w-4xl max-h-[90vh] rounded-lg shadow-lg flex flex-col">

        {/* Header */}
        <div className="p-6 border-b border-gray-300">
          <h2 className="text-xl font-semibold">Credit Details</h2>
        </div>

        <div className="px-6 py-4 overflow-y-auto flex-1 space-y-6">

          {/* Transaction Details */}
          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 border-b pb-2 border-gray-300">
              Transaction Details
            </h3>

            <div className="grid grid-cols-2 gap-4">
              <Detail label="Bill Number" value={selectedCreditDetail.billNumber} />
              <Detail label="Transaction Date" value={selectedCreditDetail.date} />
              <Detail label="Payment Type" value={selectedCreditDetail.paymentType} />
              <Detail label="Received Amount" value={selectedCreditDetail.receivedAmount} />
            </div>
          </div>

          {/* Party Information */}
          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 pb-2 border-b border-gray-300">
              Party Information
            </h3>

            <div className="grid grid-cols-2 gap-4">
              <Detail label="Supplier Name" value={selectedCreditDetail.supplierName} />

              <Detail label="Customer Name" value={selectedCreditDetail.customerName} />
            
            </div>
          </div>

          {/* Reference Details (Cheque / UPI / NEFT) */}
          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 pb-2 border-b border-gray-300">
              Reference Details
            </h3>

            <div className="grid grid-cols-2 gap-4">
              <Detail
                label="Reference Number"
                value={selectedCreditDetail.referenceNumber || "-"}
              />

              <Detail
                label="Reference Date"
                value={selectedCreditDetail.referenceDate || "-"}
              />

              <Detail
                label="Slip Number"
                value={selectedCreditDetail.slipNumber || "-"}
              />
            </div>
          </div>

          {/* Miscellaneous */}
          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 pb-2 border-b border-gray-300">
              Miscellaneous
            </h3>

            <div className="grid grid-cols-2 gap-4">
              <Detail label="Draw Type" value={selectedCreditDetail.drawType} />
              <Detail label="Remarks" value={selectedCreditDetail.remark} />
            </div>
          </div>

        </div>

        {/* Footer */}
        <div className="p-4 border-t border-gray-300 flex justify-end">
          <button
            onClick={() => setIsModalOpen(false)}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-800"
          >
            Close
          </button>
        </div>

      </div>
    </div>
  );
};

/* Reusable field component */
const Detail = ({ label, value }) => (
  <div>
    <label className="block text-sm font-medium mb-1">{label}</label>
    <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
      {value ?? "-"}
    </div>
  </div>
);

export default CreditDetail;
