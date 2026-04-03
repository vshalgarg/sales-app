import DataTable from "../components/DataTable";
import useResponsive from "../customHooks/useResponsive";
import DownloadIcon from "@mui/icons-material/Download";
import VisibilityIcon from "@mui/icons-material/Visibility";
import { useEffect, useState } from "react";
import ImagePreviewDialog from "../components/common/ImagePreviewDialog";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import { IconButton } from "@mui/material";
import FormFooter from "../components/common/FormFooter";
import AppButton from "../components/common/AppButton";
import { roundUp } from "../utils/numberUtils";
import { getBillDetails } from "../service/BillService";

const BillDetail = ({ billNumber, setIsModalOpen }) => {

  const [selectedBillDetail, setSelectedBillDetail] = useState(null);
  const [previewOpen, setPreviewOpen] = useState(false);
  const [previewIndex, setPreviewIndex] = useState(0);

  useEffect(() => {
  const fetchBillDetails = async () => {
    if (!billNumber) return;

    try {
      const data = await getBillDetails(billNumber);
      setSelectedBillDetail(data);
    } catch (err) {
      console.error("Error fetching bill details:", err.message);
    }
  };

  fetchBillDetails();
}, [billNumber]);


  const Section = ({ title, children }) => (
    <div>
      <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
        {title}
      </h3>
      {children}
    </div>
  );

  const InfoGrid = ({ cols = "md:grid-cols-2", children }) => (
    <div className={`grid grid-cols-1 ${cols} gap-4 sm:gap-6`}>
      {children}
    </div>
  );

  const Info = ({ label, value }) => (
    <div>
      <label className="block text-sm font-medium mb-1">{label}</label>
      <div className="bg-gray-100 border rounded px-3 py-2 text-sm">
        {value ?? "-"}
      </div>
    </div>
  );


 const { items = [], ...header } = selectedBillDetail || {};

  const { isMobile } = useResponsive();

  const itemColumns = {
    desktop: [
      { key: "pieces", label: "Pieces" },
      {
        key: "grossAmount",
        label: "Gross Amount",
        render: (r) => r.grossAmount?.toFixed(2),
      },
      { key: "discountPercent", label: "Disc %" },
      {
        key: "discountAmount",
        label: "Disc Amount",
        render: (r) => r.discountAmount?.toFixed(2),
      },
      {
        key: "addOnAmount",
        label: "Add-On",
        render: (r) => r.addOnAmount?.toFixed(2),
      },
      {
        key: "ecrAmount",
        label: "ECR",
        render: (r) => r.ecrAmount?.toFixed(2),
      },
      { key: "gstPercent", label: "GST %" },
      {
        key: "gstAmount",
        label: "GST Amount",
        render: (r) => r.gstAmount?.toFixed(2),
      },
    ],

    mobile: [
      { key: "pieces", label: "Qty" },
      {
        key: "grossAmount",
        label: "Amount",
        render: (r) => r.grossAmount?.toFixed(2),
      },
      {
        key: "gstAmount",
        label: "GST",
        render: (r) => r.gstAmount?.toFixed(2),
      },
    ],
  };

  const handleDownload = async (url) => {
    const response = await fetch(url);
    const blob = await response.blob();

    const blobUrl = window.URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = blobUrl;
    link.download = header.originalFileNames?.[index] || url.split("/").pop() || "download";
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.URL.revokeObjectURL(blobUrl);
  };

  if (!selectedBillDetail) return <div className="p-6">No data found</div>;

  return (
    <>
      <div className="fixed inset-0 z-50 bg-black bg-opacity-70 flex items-center justify-center">
        {/* Modal container */}
        <div
          className={`
          bg-white dark:bg-gray-900 flex flex-col
          w-full ${isMobile ? "h-full rounded-none" : "max-w-6xl max-h-[90vh] rounded-lg"}
        `}
        >
          {/* Header */}
          <div className="px-4 sm:px-6 py-4 border-b flex items-center gap-3">

            <IconButton
              onClick={() => setIsModalOpen(false)}
              className="md:hidden"
            >
              <ArrowBackIcon />
            </IconButton>

            <h2 className="text-lg sm:text-2xl font-semibold">
              Bill Details
            </h2>
          </div>

          {/* Body */}
          <div className="flex-1 overflow-y-auto px-4 sm:px-6 py-4 space-y-8">
            {/* Bill Information */}
            <Section title="Bill Information">
              <InfoGrid cols="md:grid-cols-2">
                <Info label="Bill Number" value={header.billNumber} />
                <Info label="Bill Date" value={header.date} />
                <Info label="Received Date" value={header.receivedDate} />
                <Info label="Invoice Number" value={header.invoiceNo} />
              </InfoGrid>
            </Section>

            {/* Supplier */}
            <Section title="Supplier Information">
              <InfoGrid cols="md:grid-cols-2">
                <Info label="Supplier Name" value={header.supplierName} />
                <Info label="Supplier Group" value={header.supplierGroup || "-"} />
                <Info label="MSME" value={header.supplierMsme || "-"} />
                <Info label="GSTIN" value={header.supplierGstNo || "-"} />
              </InfoGrid>
            </Section>

            {/* Customer */}
            <Section title="Customer Information">
              <InfoGrid cols="md:grid-cols-2">
                <Info label="Customer Name" value={header.customerName} />
                <Info label="Customer Group" value={header.customerGroup || "-"} />
                <Info label="MSME" value={header.customerMsme || "-"} />
                <Info label="GSTIN" value={header.customerGstNo || "-"} />
              </InfoGrid>
            </Section>

            {/* Items */}
            <Section title="Bill Items">
              <DataTable
                columns={isMobile ? itemColumns.mobile : itemColumns.desktop}
                data={items}
                actions={false}
                disablePagination
                emptyMessage="No items found"
              />

              {/* Totals */}
              <div className="mt-6 grid grid-cols-1 sm:grid-cols-2 gap-4 text-right font-semibold">
                <div>Taxable Value: ₹{roundUp(header.taxableValue)}</div>
                <div>Bill Amount: ₹{roundUp(header.billAmount)}</div>
              </div>
            </Section>

            {/* Transport */}
            <Section title="Transport & Logistics Information">
              <InfoGrid cols="md:grid-cols-3">
                <Info label="Transport" value={header.transport || "-"} />
                <Info label="LR Number" value={header.lrNumber || "-"} />
                <Info label="Remarks" value={header.remarks || "-"} />
              </InfoGrid>
            </Section>

            {/* Attachments Section */}
            <Section title={`Attachments (${header.publicUrls?.length || 0})`}>
              {header.publicUrls?.length ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {header.publicUrls.map((url, index) => {
                    const fileName = header.originalFileNames?.[index] || url.split('/').pop() || 'attachment';
                    const displayName = fileName.length > 25
                      ? fileName.substring(0, 20) + '...'
                      : fileName;

                    return (
                      <div
                        key={index}
                        className="bg-gray-100 border border-gray-300 rounded-lg p-3 flex items-center gap-3 hover:shadow-md transition-shadow"
                      >

                        {/* File Info */}
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium text-gray-700 truncate" title={fileName}>
                            {displayName}
                          </p>
                        </div>

                        {/* Actions */}
                        <div className="flex gap-1">
                          <button
                            onClick={() => {
                              setPreviewIndex(index);
                              setPreviewOpen(true);
                            }}
                            className="p-1.5 hover:bg-blue-100 rounded-full text-blue-600 transition-colors"
                            title="View"
                          >
                            <VisibilityIcon className="!text-lg" />
                          </button>
                          <button
                            onClick={() => handleDownload(url)}
                            className="p-1.5 hover:bg-green-100 rounded-full text-green-600 transition-colors"
                            title="Download"
                          >
                            <DownloadIcon className="!text-lg" />
                          </button>
                        </div>
                      </div>
                    );
                  })}
                </div>
              ) : (
                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-8 text-center">
                  <VisibilityIcon className="!text-4xl text-gray-400 mb-2" />
                  <p className="text-gray-500">No attachments</p>
                </div>
              )}
            </Section>

          </div>

          {/* Footer */}
          <FormFooter background="bg-white">

            <AppButton
              type="primary"
              onClick={() => setIsModalOpen(false)}
              sx={{ minWidth: "140px" }}
            >
              Close
            </AppButton>

          </FormFooter>

        </div>
      </div>
      <ImagePreviewDialog
        open={previewOpen}
        images={header.publicUrls || []}
        index={previewIndex}
        onClose={() => setPreviewOpen(false)}
        onChangeIndex={setPreviewIndex}
      />
    </>
  );
};

export default BillDetail;