const CustomerDetail = ({ selectedCustomer, setModalOpen }) => {
  return (
    <>
      <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
        <div className="bg-white w-full max-w-4xl max-h-[90vh] rounded-lg shadow-lg flex flex-col">
          <div className="p-6 border-b boder-gray-300">
            <h2 className="text-xl font-semibold">Customer Details</h2>
          </div>

          <div className="px-6 py-4 overflow-y-auto flex-1 space-y-6">
            {/* Section: Basic Information */}
            <h3 className="text-lg font-semibold mb-3">Basic Information</h3>
            <div className="grid grid-cols-2 gap-4 mb-6">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Customer Name
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedCustomer.customerName}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Group Name
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedCustomer.customerGroup}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  GST Number
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedCustomer.customerGstNo}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">MSME</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedCustomer.customerMsme}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Referenced By
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedCustomer.referencedBy}
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
                  {selectedCustomer.address}
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
                  {selectedCustomer.city}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Pin Code
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedCustomer.pinCode}
                </div>
              </div>
            </div>

            {/* Section: Contact Information */}
            <h3 className="text-lg font-semibold mb-3">Contact Information</h3>
            {selectedCustomer.contacts.map((c, idx) => (
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

            {/* Section: Other Info */}
            <h3 className="text-lg font-semibold mb-3">Other Information</h3>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Preferred Transport
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedCustomer.preferredTransport?.join(", ")}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Remark</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedCustomer.remark}
                </div>
              </div>
            </div>

            {/* Footer Button */}
          </div>
          <div className="p-4 border-t boder-gray-300 flex justify-end space-x-3">
            <button
              onClick={() => setModalOpen(false)}
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

export default CustomerDetail;
