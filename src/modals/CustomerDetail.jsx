import { useEffect } from "react";
import { Button, IconButton } from "@mui/material";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import FormFooter from "../components/common/FormFooter";
import AppButton from "../components/common/AppButton";

const CustomerDetail = ({ selectedCustomer, setModalOpen }) => {

  useEffect(() => {
  }, [selectedCustomer]);
  return (
    <>
      <div className="fixed inset-0 bg-black bg-opacity-50 z-50 md:flex md:items-center md:justify-center">
        <div className="bg-white w-full h-screen  md:max-w-4xl md:max-h-[90vh] md:rounded-lg shadow-lg flex flex-col">
          <div className="px-3 py-2 md:p-6 border-b border-gray-300 sticky top-0 bg-white z-10 flex items-center gap-3">
            {/*Back Arrow */}
            <IconButton
              onClick={() => setModalOpen(false)}
              className="md:hidden"
              size="small"
            >
              <ArrowBackIcon />
            </IconButton>

            <h2 className="text-lg md:text-xl font-semibold">
              Customer Details
            </h2>

          </div>

          <div className="px-6 py-2 md:py-4 overflow-y-auto flex-1 space-y-4 md:space-y-6">
            {/* Section: Basic Information */}
            <h3 className="md:text-lg font-semibold mb-3">Basic Information</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-4 ">
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
                  Email
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-words">
                  {selectedCustomer.email || "-"}
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
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-all">
                  {selectedCustomer.customerGstNo || "-"}
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
            <h3 className="md:text-lg font-semibold mb-3">Address Details</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-4 ">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Address
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-words whitespace-pre-wrap">
                  {[
                    selectedCustomer.address
                  ].filter(Boolean).join(", ") || "-"}
                </div>

              </div>
              <div>
                <label className="block text-sm font-medium mb-1">State</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedCustomer.state}
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
            <h3 className="md:text-lg font-semibold mb-3">Contact Information</h3>
            {Array.isArray(selectedCustomer.contacts) && selectedCustomer.contacts.length > 0 ? (
              selectedCustomer.contacts.map((c, idx) => (
                <div className="grid grid-cols-1 md:grid-cols-3 gap-2 md:gap-4" key={idx}>
                  <div>
                    <label className="block text-sm font-medium mb-1">Contact Person</label>
                    <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                      {c.contactPerson || "-"}
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-1">Mobile No.</label>
                    <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                      {c.mobileNumber || "-"}
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-1">Type</label>
                    <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-words">
                      {c.type || "-"}
                    </div>
                  </div>

                </div>
              ))
            ) : (
              <div className="bg-gray-50 border border-gray-200 rounded p-4 text-center text-gray-500">
                No contact information available
              </div>
            )}

            {/* ------------------ Other Information ------------------ */}
            <h3 className="md:text-lg font-semibold mb-3">Other Information</h3>
            <div className="grid  grid-cols-1 md:grid-cols-2 gap-2 md:gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">Preferred Transport</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 flex flex-wrap gap-2 items-center">
                  {Array.isArray(selectedCustomer.preferredTransports) && selectedCustomer.preferredTransports.length > 0 ? (
                    selectedCustomer.preferredTransports.map((transport, idx) => (
                      <span
                        key={idx}
                        className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-xs"
                      >
                        {transport.name || transport.transportName || "Unnamed"}
                      </span>
                    ))
                  ) : (
                    <span className="text-gray-500 text-sm">-</span>
                  )}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Remark</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9">
                  {selectedCustomer.remark || "-"}
                </div>
              </div>
            </div>
          </div>

          {/* Footer Button */}
          <FormFooter>

            <AppButton
              type="cancel"
              onClick={() => setModalOpen(false)}
            >
              Cancel
            </AppButton>

          </FormFooter>

        </div>
      </div>
    </>
  );
};

export default CustomerDetail;
