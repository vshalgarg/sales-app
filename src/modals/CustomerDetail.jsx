import { useEffect } from "react";
import { Button, IconButton } from "@mui/material";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import FormFooter from "../components/common/FormFooter";
import AppButton from "../components/common/AppButton";
import { useState } from "react";
import ContentCopyIcon from "@mui/icons-material/ContentCopy";
import { Tooltip } from "@mui/material";
import CopyDetailsModal from "../components/common/CopyDetailsModal";
import { getCustomerFormattedText } from "../utils/copyFormatter";
import CustomerService from "../service/CustomerService";

const CustomerDetail = ({ customerId, setModalOpen }) => {

  const [customer, setCustomer] = useState(null);
  const [loading, setLoading] = useState(true);
  const [copyModalOpen, setCopyModalOpen] = useState(false);

  useEffect(() => {
    if (!customerId) return;

    const fetchCustomer = async () => {
      try {
        setLoading(true);

        const response = await CustomerService.getCustomerById(customerId);
        const data = response.data || response;

        setCustomer(data);
      } catch (err) {
        console.error("Failed to fetch customer details:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchCustomer();
  }, [customerId]);


if (loading) {
    return <div className="p-6">Loading supplier details...</div>;
  }

  if (!customer) {
    return <div className="p-6">No data found</div>;
  }

  return (
    <>
      <div className="fixed inset-0 bg-black bg-opacity-50 z-50 md:flex md:items-center md:justify-center">
        <div className="bg-white w-full h-screen  md:max-w-4xl md:max-h-[90vh] md:rounded-lg shadow-lg flex flex-col">

          {/* header */}
          <div className="px-3 py-2 md:p-6 border-b border-gray-300 sticky top-0 bg-white z-10 flex items-center gap-3">
            {/*Back Arrow */}
            <IconButton
              onClick={() => setModalOpen(false)}
              className="md:hidden"
              size="small"
            >
              <ArrowBackIcon />
            </IconButton>

            <div className="flex items-center justify-between w-full">
              <h2 className="text-lg md:text-xl font-semibold">
                Customer Details
              </h2>

              <Tooltip title="Copy Details">
                <IconButton
                  onClick={() => setCopyModalOpen(true)}
                  size="small"
                >
                  <ContentCopyIcon fontSize="small" />
                </IconButton>
              </Tooltip>
            </div>

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
                  {customer.customerName || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Email
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-words">
                  {customer.email || "-"}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">
                  Group Name
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {customer.groupName || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  GST Number
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-all">
                  {customer.gstNo || "-"}
                </div>

              </div>
              <div>
                <label className="block text-sm font-medium mb-1">MSME</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {customer.msme || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Referenced By
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {customer.referencedBy || "-"}
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
                  {[customer.addressLine1, customer.addressLine2].filter(Boolean).join(", ") || "-"}
                </div>

              </div>
              <div>
                <label className="block text-sm font-medium mb-1">State</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {customer.state || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">City</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {customer.city || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Pin Code
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {customer.pinCode || "-"}
                </div>
              </div>
            </div>

            {/* Bank Details */}
            <h3 className="md:text-lg font-semibold mb-3">Bank Details</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">Bank Name</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {customer.bankName || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">IFSC</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {customer.ifsc || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Branch</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {customer.branch || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Account Name</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {customer.accountName || "-"}
                </div>
              </div>
              <div className="md:col-span-2">
                <label className="block text-sm font-medium mb-1">Account Number</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {customer.accountNumber || "-"}
                </div>
              </div>
            </div>

            {/* Section: Contact Information */}
            <h3 className="md:text-lg font-semibold mb-3">Contact Information</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">Preferred Transport</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 flex flex-wrap gap-2 items-center">
                  {Array.isArray(customer.preferredTransports) && customer.preferredTransports.length > 0 ? (
                    customer.preferredTransports.map((transport, idx) => (
                      <span
                        key={idx}
                        className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-xs"
                      >
                        {transport.name || "Unnamed"}
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
                  {customer.remark || "-"}
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

          {copyModalOpen && (
            <CopyDetailsModal
              open={copyModalOpen}
              onClose={() => setCopyModalOpen(false)}
              title="Copy Customer Details"
              formattedText={getCustomerFormattedText(customer)}
            />
          )}

        </div>
      </div>
    </>
  );
};

export default CustomerDetail;
