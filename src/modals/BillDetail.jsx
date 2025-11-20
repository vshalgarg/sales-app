const BillDetail = ({ selectedBillDetail, setIsModalOpen }) => {
  return (
    <>
      <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-80 z-50">
        <div className="bg-white dark:bg-gray-900 w-full max-w-4xl max-h-[90vh] rounded-lg shadow-lg flex flex-col">
          <div className="p-6 border-b">
            <h2 className="text-xl font-semibold">Bill Details</h2>
          </div>

          <div className="px-6 py-4 overflow-y-auto flex-1 space-y-6">
            {/* Section: Basic Information */}
            <h3 className="text-lg font-semibold mb-3 border-b border-gray-300">
              Bill Information
            </h3>
            <div className="sup-info grid grid-cols-2 gap-4 mb-6">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Bill Number
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.billNumber}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Bill Date
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.date}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Received Date
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.receivedDate}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Order</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.order}
                </div>
              </div>
            </div>

            <h3 className="text-lg font-semibold mb-3">Supplier Information</h3>
            <div className="sup-info grid grid-cols-2 gap-4 mb-6">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Supplier Name
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.supplierName}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Supplier Group
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.supplierGroup}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">MSME</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.supplierMsme}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">GSTIN</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.supplierGstNo}
                </div>
              </div>
            </div>

            <h3 className="text-lg font-semibold mb-3">Customer Information</h3>
            <div className="sup-info grid grid-cols-2 gap-4 mb-6">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Customer Name
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.customerName}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Customer Group
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.customerGroup}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">MSME</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.customerMsme}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">GSTIN</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.customerGstNo}
                </div>
              </div>
            </div>

            {/* Section: Address Details */}
            <h3 className="text-lg font-semibold mb-3">Amount Information</h3>
            <div className="grid grid-cols-2 gap-4 mb-6">
              <div>
                <label className="block text-sm font-medium mb-1">Pieces</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.pieces}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Gross Amount
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.grossAmount}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Discount %
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.discountPercent}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Discount Amount
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.discountAmount}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Add-On Amount
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.addOnAmount}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  ECR Amount
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.ecrAmount}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">GST %</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.gstPercent}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  GST Amount
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.gstAmount}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Taxable Value
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.taxableValue}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Bill Amount
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.billAmount}
                </div>
              </div>
            </div>

            {/* Section: Other Info */}
            <h3 className="text-lg font-semibold mb-3">
              Transport & Logistics Information
            </h3>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Transport
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.transport}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  LR Number
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.lrNumber}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Remark</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm">
                  {selectedBillDetail.remarks}
                </div>
              </div>
            </div>

            {/* Footer Button */}
          </div>
          <div className="p-4 border-t flex justify-end space-x-3">
            <button
              onClick={() => setIsModalOpen(false)}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </>
  );
};
export default BillDetail;
