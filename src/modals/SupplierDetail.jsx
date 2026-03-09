import { IconButton, Tooltip } from "@mui/material";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import FormFooter from "../components/common/FormFooter";
import AppButton from "../components/common/AppButton";
import ContentCopyIcon from "@mui/icons-material/ContentCopy";
import CopyDetailsModal from "../components/common/CopyDetailsModal";
import { useState } from "react";

const SupplierDetail = ({ selectedSupplier, setIsModalOpen }) => {
  const [copyModalOpen, setCopyModalOpen] = useState(false);
  const getSupplierFormattedText = (supplier) => {

    const mobileNumbers = supplier?.contacts
      ?.map(contact => contact.mobileNumber)
      ?.filter(Boolean)
      ?.join(", ") || "-";

    const fullAddress = [
      supplier?.address,
      supplier?.city,
      supplier?.state,
      supplier?.pinCode
    ]
      .filter(Boolean)
      .join(", ");

    return `Firm Name: ${supplier?.supplierName || "-"}
Address: ${fullAddress || "-"}
Phone No: ${mobileNumbers}
GST No: ${supplier?.supplierGstNo || "-"}`;
  };

  return (
    <>
      <div className="fixed inset-0 bg-black bg-opacity-50 z-50 md:flex md:items-center md:justify-center">
        <div className="bg-white dark:bg-gray-900 w-full h-screen md:max-w-4xl md:max-h-[90vh]  md:rounded-lg shadow-lg flex flex-col">
          <div className="px-3 py-2 md:p-6 border-b border-gray-300 sticky top-0 bg-white z-10 flex items-center gap-3">

            {/*Back Button */}
            <IconButton
              onClick={() => setIsModalOpen(false)}
              className="md:hidden"
              size="small"
            >
              <ArrowBackIcon />
            </IconButton>

            <div className="flex items-center justify-between w-full">
              <h2 className="text-lg md:text-xl font-semibold">
                Supplier Details
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
            <h3 className="md:text-lg font-semibold md:mb-3">
              Basic Information
            </h3>
            <div className="sup-info grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-4">
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
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-all">
                  {selectedSupplier.supplierGstNo}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">MSME</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedSupplier.supplierMsme}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">
                  Email
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-words">
                  {selectedSupplier.email || "-"}
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

              <div>
                <label className="block text-sm font-medium mb-1">
                  Reference By
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-words">
                  {selectedSupplier.referenceBy || "-"}
                </div>
              </div>

            </div>

            {/* Section: Address Details */}
            <h3 className="md:text-lg font-semibold mb-3">Address Details</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Address
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-words whitespace-pre-wrap">
                  {selectedSupplier.address || "-"}
                </div>

              </div>
              <div>
                <label className="block text-sm font-medium mb-1">State</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {selectedSupplier.state}
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
            <h3 className="md:text-lg font-semibold mb-3">
              Contact Information
            </h3>
            {selectedSupplier.contacts.map((c, idx) => (
              <div className="grid grid-cols-1 md:grid-cols-3 gap-2 md:gap-4" key={idx}>
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
                    Type
                  </label>
                  <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-words">
                    {c.type || "-"}
                  </div>
                </div>

              </div>
            ))}

            {/* Section: Other Information */}
            <h3 className="md:text-lg font-semibold mb-3">Other Information</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Preferred Transport
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 flex flex-wrap gap-2 items-center">
                  {selectedSupplier.preferredTransports ? (
                    selectedSupplier.preferredTransports.length > 0 ? (
                      selectedSupplier.preferredTransports.map(
                        (transport, idx) => (
                          <span
                            key={idx}
                            className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-xs"
                          >
                            {transport.name || "Unknown"}
                          </span>
                        ),
                      )
                    ) : (
                      <span className="text-gray-500 text-sm">
                        No transports
                      </span>
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

          </div>

          {/* Footer Button */}
          <FormFooter>

            <AppButton
              type="cancel"
              onClick={() => setIsModalOpen(false)}
            >
              Cancel
            </AppButton>

          </FormFooter>

          {copyModalOpen && (
            <CopyDetailsModal
              open={copyModalOpen}
              onClose={() => setCopyModalOpen(false)}
              title="Copy Supplier Details"
              formattedText={getSupplierFormattedText(selectedSupplier)}
            />
          )}

        </div>
      </div>
    </>
  );
};

export default SupplierDetail;
