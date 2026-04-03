import { IconButton, Tooltip } from "@mui/material";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import FormFooter from "../components/common/FormFooter";
import AppButton from "../components/common/AppButton";
import ContentCopyIcon from "@mui/icons-material/ContentCopy";
import CopyDetailsModal from "../components/common/CopyDetailsModal";
import { useState, useEffect } from "react";
import SupplierService from "../service/SupplierService";
import { getSupplierFormattedText } from "../utils/copyFormatter";
import { useSnackbar } from "../context/SnackbarContext";

const SupplierDetail = ({ supplierId, setIsModalOpen }) => {
  const [copyModalOpen, setCopyModalOpen] = useState(false);
  const [supplier, setSupplier] = useState(null);
  const { showSnackbar } = useSnackbar();

  useEffect(() => {
    const fetchSupplier = async () => {
      try {
        const res = await SupplierService.getSupplierById(supplierId);
        setSupplier(res.data);
      } catch (error) {
        console.error(error);
        showSnackbar( err?.message ||"Failed to load supplier", "error");
      } 
    };

    fetchSupplier();
  }, [supplierId]);

  if (!supplier) return null;

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
                  {supplier.supplierName || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Group Name
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {supplier.groupName || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  GST Number
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-all">
                  {supplier.gstNo || "-"}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">MSME</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {supplier.msme || "-"}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">
                  Email
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-words">
                  {supplier.email || "-"}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">
                  Commission Scheme
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {supplier.commissionScheme || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Commission %
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {supplier.commissionRate ?? "-"}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">
                  Reference By
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 break-words">
                  {supplier.referenceBy || "-"}
                </div>
              </div>

            </div>

            <h3 className="md:text-lg font-semibold mb-3">Bank Details</h3>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-4">

              <div>
                <label className="block text-sm font-medium mb-1">Bank Name</label>
                <div className="bg-gray-100 border rounded px-3 py-2 text-sm h-9">
                  {supplier.bankName || "-"}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">IFSC Code</label>
                <div className="bg-gray-100 border rounded px-3 py-2 text-sm h-9">
                  {supplier.ifscCode || "-"}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Branch</label>
                <div className="bg-gray-100 border rounded px-3 py-2 text-sm h-9">
                  {supplier.branchName || "-"}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Account Name</label>
                <div className="bg-gray-100 border rounded px-3 py-2 text-sm h-9">
                  {supplier.accountName || "-"}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Account Number</label>
                <div className="bg-gray-100 border rounded px-3 py-2 text-sm h-9">
                  {supplier.accountNumber || "-"}
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
                  {[
                    supplier.addressLine1,
                    supplier.addressLine2,
                    supplier.city ? `${supplier.city},` : "",
                    supplier.state ? `${supplier.state} -` : "",
                    supplier.pinCode,
                  ]
                    .filter(Boolean)
                    .join(" ")
                    .trim() || "-"}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">State</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {supplier.state || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">City</label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {supplier.city || "-"}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  Pin Code
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                  {supplier.pinCode || "-"}
                </div>
              </div>
            </div>

            {/* Section: Contact Information */}
            <h3 className="md:text-lg font-semibold mb-3">
              Contact Information
            </h3>
            {supplier.contacts?.length > 0 ? (
              supplier.contacts.map((c, idx) => (
                <div
                  key={idx}
                  className="grid grid-cols-1 md:grid-cols-3 gap-2 md:gap-4 mb-3"
                >
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
                    <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9">
                      {c.type || "-"}
                    </div>
                  </div>
                </div>
              ))
            ) : (
              <div className="text-gray-500">No contacts available</div>
            )}

            {/* Section: Other Information */}
            <h3 className="md:text-lg font-semibold mb-3">Other Information</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Preferred Transport
                </label>
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9 flex flex-wrap gap-2 items-center">
                  {supplier.preferredTransports ? (
                    supplier.preferredTransports.length > 0 ? (
                      supplier.preferredTransports.map(
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
                  {supplier.remark || "-"}
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
              formattedText={getSupplierFormattedText(supplier)}
            />
          )}

        </div>
      </div>
    </>
  );
};

export default SupplierDetail;
