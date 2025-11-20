const CreditDetail = ({ selectedCreditDetail, setIsModalOpen }) => {
  return (
    <>
      <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-80 z-50">
        <div className="bg-white dark:bg-gray-900 w-full max-w-4xl max-h-[90vh] rounded-lg shadow-lg flex flex-col">
          <div className="p-6 border-b border-gray-300">
            <h2 className="text-xl font-semibold">Credit Details</h2>
          </div>

          <div className="px-6 py-4 overflow-y-auto flex-1 space-y-6 ">
            <div className="border p-4 rounded border-gray-300">
              {/* Section: Basic Information */}
              <h3 className="text-lg font-semibold mb-3 border-b pb-2  border-gray-300">
                Transaction Details
              </h3>
              <div className="sup-info grid grid-cols-2 gap-4 ">
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Bill Number
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.billNumber}
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Date</label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.date}
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Payment Type
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.paymentType}
                  </div>
                </div>
              </div>
            </div>

            <div className="border p-4 rounded border-gray-300">
              <h3 className="text-lg font-semibold mb-3 pb-2 border-b border-gray-300">
                Party Information
              </h3>
              <div className="sup-info grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1 ">
                    Supplier Name
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.supplierName}
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Supplier Current Balance
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.supplierCurrentBalance}
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1">
                    Customer Name
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.customerName}
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Customer Current Balance
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.customerCurrentBalance}
                  </div>
                </div>
              </div>
            </div>

            <div className="border p-4 rounded border-gray-300">
              {/* Section: Address Details */}
              <h3 className="text-lg font-semibold mb-3 pb-2 border-b border-gray-300">
                Cheque Details
              </h3>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Cheque Date
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.chequeDate}
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Cheque Number
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.chequeNumber}
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Received Amount
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.receivedAmount}
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Slip Number
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.slipNumber}
                  </div>
                </div>
              </div>
            </div>

            {/* Section: Other Info */}
            <div className="border p-4 rounded border-gray-300">
              <h3 className="text-lg font-semibold mb-3 pb-2 border-b border-gray-300">
                Miscellaneous
              </h3>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Draw/Cheque
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.drawType}
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Remarks
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {selectedCreditDetail.remark}
                  </div>
                </div>
              </div>
            </div>

            {/* Footer Button */}
          </div>
          <div className="p-4 border-t border-gray-300 flex justify-end space-x-3">
            <button
              onClick={() => setIsModalOpen(false)}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-800"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </>
  );
};

export default CreditDetail;
