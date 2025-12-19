const SupplierDetail = ({ selectedSupplier, setIsModalOpen }) => {
  return (
    <>
      <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50 ">
        <div className="bg-white dark:bg-gray-900 w-full max-w-4xl max-h-[90vh] rounded-lg shadow-lg flex flex-col">
          <div className="p-6 border-b border-gray-300">
            <h2 className="text-xl font-semibold">Supplier Details</h2>
          </div>

          <div className="px-6 py-4 overflow-y-auto flex-1 space-y-6">
            {/* Section: Basic Information */}
            <h3 className="text-lg font-semibold mb-3">Basic Information</h3>
            <div className="sup-info grid grid-cols-2 gap-4 mb-6">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Supplier Name
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedSupplier.supplierName}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Group Name
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedSupplier.supplierGroup}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  GST Number
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedSupplier.supplierGstNo}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Commission Scheme
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedSupplier.commissionScheme}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Commission %
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedSupplier.commissionRate}
                </div>
              </div>
            </div>

            {/* Section: Address Details */}
            <h3 className="text-lg font-semibold mb-3">Address Details</h3>
            <div className="grid grid-cols-2 gap-4 mb-6">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Address
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedSupplier.address}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">State</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  Haryana
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">City</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedSupplier.city}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Pin Code
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedSupplier.pinCode}
                </div>
              </div>
            </div>

            {/* Section: Contact Information */}
            <h3 className="text-lg font-semibold mb-3">Contact Information</h3>
            {selectedSupplier.contacts.map((c, idx) => (
              <div className="grid grid-cols-3 gap-4 mb-4" key={idx}>
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Contact Person
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {c.contactPerson}
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Mobile No.
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {c.mobileNumber}
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">
                    Phone No.
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                    {c.phone}
                  </div>
                </div>
              </div>
            ))}

            {/* Section: Other Information */}
            <h3 className="text-lg font-semibold mb-3">Other Information</h3>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Preferred Transport
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 flex flex-wrap gap-2 items-center">
                  {selectedSupplier.preferredTransports ? (
                    selectedSupplier.preferredTransports.length > 0 ? (
                      selectedSupplier.preferredTransports.map((transport, idx) => (
                        <span
                          key={idx}
                          className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-xs"
                        >
                          {transport.name || "Unknown"}
                        </span>
                      ))
                    ) : (
                      <span className="text-gray-500 text-sm">No transports</span>
                    )
                  ) : (
                    <span className="text-gray-500 text-sm">-</span>
                  )}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Remark</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9">
                  {selectedSupplier.remark || "-"}
                </div>
              </div>
            </div>

            {/* Footer Button */}
          </div>
          <div className="p-4 border-t border-gray-300 flex justify-end space-x-3">
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

export default SupplierDetail;
