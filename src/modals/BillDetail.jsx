const BillDetail = ({ selectedBillDetail, setIsModalOpen }) => {

  if (!selectedBillDetail) return null;

  const { items = [], ...header } = selectedBillDetail;

  return (
    <>
      <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-80 z-50">
        <div className="bg-white dark:bg-gray-900 w-full max-w-6xl max-h-[90vh] rounded-lg shadow-lg flex flex-col">
          <div className="p-6 border-b flex justify-between items-center">
            <h2 className="text-2xl font-semibold">Bill Details</h2>
            <button onClick={() => setIsModalOpen(false)} className="text-gray-500 hover:text-gray-700 text-2xl">
              ×
            </button>
          </div>

          <div className="px-6 py-4 overflow-y-auto flex-1 space-y-8">

            {/* ====== 1. Bill Information (same as before) ====== */}
            <div>
              <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">Bill Information</h3>
              <div className="grid grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium mb-1">Bill Number</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.billNumber}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Bill Date</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.date}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Received Date</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.receivedDate}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Order</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.order}</div>
                </div>
              </div>
            </div>

            {/* ====== 2. Supplier Information ====== */}
            <div>
              <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">Supplier Information</h3>
              <div className="grid grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium mb-1">Supplier Name</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.supplierName}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Supplier Group</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.supplierGroup || "-"}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">MSME</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.supplierMsme || "-"}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">GSTIN</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.supplierGstNo || "-"}</div>
                </div>
              </div>
            </div>

            {/* ====== 3. Customer Information ====== */}
            <div>
              <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">Customer Information</h3>
              <div className="grid grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium mb-1">Customer Name</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.customerName}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Customer Group</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.customerGroup || "-"}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">MSME</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.customerMsme || "-"}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">GSTIN</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.customerGstNo || "-"}</div>
                </div>
              </div>
            </div>

            {/* ====== 4.Items Table ====== */}
            <div>
              <h3 className="text-lg font-semibold mb-4 border-b border-gray-300 pb-2">Bill Items</h3>
              {items && items.length > 0 ? (
                <div className="overflow-x-auto">
                  <table className="min-w-full border border-gray-300">
                    <thead className="bg-gray-100">
                      <tr>
                        <th className="px-4 py-2 text-left text-sm font-medium">Pieces</th>
                        <th className="px-4 py-2 text-left text-sm font-medium">Gross Amount</th>
                        <th className="px-4 py-2 text-left text-sm font-medium">Disc %</th>
                        <th className="px-4 py-2 text-left text-sm font-medium">Disc Amount</th>
                        <th className="px-4 py-2 text-left text-sm font-medium">Add-On</th>
                        <th className="px-4 py-2 text-left text-sm font-medium">ECR</th>
                        <th className="px-4 py-2 text-left text-sm font-medium">GST %</th>
                        <th className="px-4 py-2 text-left text-sm font-medium">GST Amount</th>
                      </tr>
                    </thead>
                    <tbody>
                      {items.map((item, index) => (
                        <tr key={index} className="border-t">
                          <td className="px-4 py-2 text-sm">{item.pieces}</td>
                          <td className="px-4 py-2 text-sm">{item.grossAmount.toFixed(2)}</td>
                          <td className="px-4 py-2 text-sm">{item.discountPercent}</td>
                          <td className="px-4 py-2 text-sm">{item.discountAmount.toFixed(2)}</td>
                          <td className="px-4 py-2 text-sm">{item.addOnAmount.toFixed(2)}</td>
                          <td className="px-4 py-2 text-sm">{item.ecrAmount.toFixed(2)}</td>
                          <td className="px-4 py-2 text-sm">{item.gstPercent}</td>
                          <td className="px-4 py-2 text-sm">{item.gstAmount.toFixed(2)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <p className="text-gray-500 text-center py-4">No items found</p>
              )}

              {/* Totals */}
              <div className="mt-6 grid grid-cols-2 text-right font-bold text-lg">
                <div>Taxable Value: ₹{header.taxableValue?.toFixed(2) || "0.00"}</div>
                <div>Bill Amount: ₹{header.billAmount?.toFixed(2) || "0.00"}</div>
              </div>
            </div>

            {/* ====== 5. Transport & Logistics (same as before) ====== */}
            <div>
              <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
                Transport & Logistics Information
              </h3>
              <div className="grid grid-cols-3 gap-6">
                <div>
                  <label className="block text-sm font-medium mb-1">Transport</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.transport || "-"}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">LR Number</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.lrNumber || "-"}</div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Remarks</label>
                  <div className="bg-gray-100 border rounded px-3 py-2 text-sm">{header.remarks || "-"}</div>
                </div>
              </div>
            </div>

          </div>

          {/* Footer */}
          <div className="p-6 border-t flex justify-end">
            <button
              onClick={() => setIsModalOpen(false)}
              className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    </>
  );
};

export default BillDetail;