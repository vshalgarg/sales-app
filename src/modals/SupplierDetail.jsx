import { IconButton, Tooltip } from "@mui/material";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import ContentCopyIcon from "@mui/icons-material/ContentCopy";
import { useState, useEffect } from "react";
import {
  Building2,
  MapPin,
  Phone,
  Truck,
  Landmark,
} from "lucide-react";
import FormFooter from "../components/common/FormFooter";
import FormSection from "../components/common/FormSection";
import DetailField from "../components/common/DetailField";
import {
  FORM_SCROLL_AREA_CLASS,
  TRANSPORT_CHIP_CLASS,
  DETAIL_FIELD_VALUE_CLASS,
} from "../theme/cardTheme";
import AppButton from "../components/common/AppButton";
import CopyDetailsModal from "../components/common/CopyDetailsModal";
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
        showSnackbar(error?.message || "Failed to load supplier", "error");
      }
    };

    fetchSupplier();
  }, [supplierId, showSnackbar]);

  if (!supplier) return null;

  const fullAddress =
    [
      supplier.addressLine1,
      supplier.addressLine2,
      supplier.city ? `${supplier.city},` : "",
      supplier.state ? `${supplier.state} -` : "",
      supplier.pinCode,
    ]
      .filter(Boolean)
      .join(" ")
      .trim() || "-";

  return (
    <>
      <div className="fixed inset-0 bg-black bg-opacity-50 z-50 md:flex md:items-center md:justify-center">
        <div className="bg-white dark:bg-gray-900 w-full h-screen md:max-w-5xl md:max-h-[90vh] md:rounded-lg shadow-lg flex flex-col">
          <div className="px-3 py-2 md:p-6 border-b border-gray-300 dark:border-zinc-700 sticky top-0 bg-white dark:bg-gray-900 z-10 flex items-center gap-3">
            <IconButton
              onClick={() => setIsModalOpen(false)}
              size="small"
              aria-label="Go back"
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

          <div className={`px-4 md:px-6 py-4 overflow-y-auto flex-1 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}>
            <FormSection title="Basic Information" icon={Building2} variantIndex={0}>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <DetailField label="Supplier Name">
                  {supplier.supplierName || "-"}
                </DetailField>
                <DetailField label="Email">{supplier.email || "-"}</DetailField>
                <DetailField label="Group Name">
                  {supplier.groupName || "-"}
                </DetailField>
                <DetailField label="GST Number" valueClassName="break-all">
                  {supplier.gstNo || "-"}
                </DetailField>
                <DetailField label="MSME">{supplier.msme || "-"}</DetailField>
                <DetailField label="Commission Scheme">
                  {supplier.commissionScheme || "-"}
                </DetailField>
                <DetailField label="Commission %">
                  {supplier.commissionRate ?? "-"}
                </DetailField>
                <DetailField label="Reference By">
                  {supplier.referenceBy || "-"}
                </DetailField>
              </div>
            </FormSection>

            <FormSection title="Address Details" icon={MapPin} variantIndex={1}>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <DetailField
                  label="Address"
                  valueClassName="whitespace-pre-wrap"
                >
                  {fullAddress}
                </DetailField>
                <DetailField label="State">{supplier.state || "-"}</DetailField>
                <DetailField label="City">{supplier.city || "-"}</DetailField>
                <DetailField label="Pin Code">
                  {supplier.pinCode || "-"}
                </DetailField>
              </div>
            </FormSection>

            <FormSection title="Contact Information" icon={Phone} variantIndex={2}>
              {supplier.contacts?.length > 0 ? (
                supplier.contacts.map((c, idx) => (
                  <div
                    key={idx}
                    className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4 last:mb-0"
                  >
                    <DetailField label="Contact Person">
                      {c.contactPerson || "-"}
                    </DetailField>
                    <DetailField label="Mobile No.">
                      {c.mobileNumber || "-"}
                    </DetailField>
                    <DetailField label="Type">{c.type || "-"}</DetailField>
                  </div>
                ))
              ) : (
                <div className="text-gray-500">No contacts available</div>
              )}
            </FormSection>

            <FormSection title="Preferred Transports" icon={Truck} variantIndex={3}>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1 text-gray-700 dark:text-gray-300">
                    Preferred Transport
                  </label>
                  <div className={`rounded px-3 py-2 text-sm min-h-9 flex flex-wrap gap-2 items-center border ${DETAIL_FIELD_VALUE_CLASS}`}>
                    {supplier.preferredTransports?.length > 0 ? (
                      supplier.preferredTransports.map((transport, idx) => (
                        <span
                          key={idx}
                          className={`px-3 py-1 rounded-full text-xs ${TRANSPORT_CHIP_CLASS}`}
                        >
                          {transport.name || "Unknown"}
                        </span>
                      ))
                    ) : (
                      <span className="text-gray-500 text-sm">No transports</span>
                    )}
                  </div>
                </div>
                <DetailField label="Remark">{supplier.remark || "-"}</DetailField>
              </div>
            </FormSection>

            <FormSection title="Bank Details" icon={Landmark} variantIndex={4}>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <DetailField label="Bank Name">
                  {supplier.bankName || "-"}
                </DetailField>
                <DetailField label="IFSC Code">
                  {supplier.ifscCode || "-"}
                </DetailField>
                <DetailField label="Branch Name">
                  {supplier.branchName || "-"}
                </DetailField>
                <DetailField label="Account Holder Name">
                  {supplier.accountName || "-"}
                </DetailField>
                <DetailField label="Account Number">
                  {supplier.accountNumber || "-"}
                </DetailField>
              </div>
            </FormSection>
          </div>

          <FormFooter>
            <AppButton type="cancel" onClick={() => setIsModalOpen(false)}>
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
