import DataTable from "../components/DataTable";
import useResponsive from "../customHooks/useResponsive";
import DownloadIcon from "@mui/icons-material/Download";
import VisibilityIcon from "@mui/icons-material/Visibility";
import { useEffect, useMemo, useState } from "react";
import ImagePreviewDialog from "../components/common/ImagePreviewDialog";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import CloseIcon from "@mui/icons-material/Close";
import { IconButton } from "@mui/material";
import FormFooter from "../components/common/FormFooter";
import AppButton from "../components/common/AppButton";
import FormSection from "../components/common/FormSection";
import DetailField from "../components/common/DetailField";
import ModalSectionLayout from "../components/common/ModalSectionLayout";
import {
  BILL_SECTION_IDS,
  getBillModalSections,
} from "../components/common/billModalSections";
import { useModalSectionNav } from "../customHooks/useModalSectionNav";
import { roundUp } from "../utils/numberUtils";
import { getBillDetails } from "../service/BillService";
import { formatIndianCurrency } from "../utils/currencyUtils";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";
import {
  Building2,
  FileText,
  Paperclip,
  Receipt,
  Truck,
  Users,
} from "lucide-react";

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

  const { items = [], ...header } = selectedBillDetail || {};
  const { isMobile } = useResponsive();

  const attachmentCount = header.publicUrls?.length || 0;
  const sections = useMemo(
    () => getBillModalSections(attachmentCount),
    [attachmentCount],
  );
  const sectionIds = useMemo(() => sections.map((section) => section.id), [sections]);

  const { activeSection, scrollToSection, scrollContainerRef, setSectionRef } =
    useModalSectionNav(sectionIds, { enabled: !!selectedBillDetail });

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

  const handleDownload = async (url, index) => {
    const response = await fetch(url);
    const blob = await response.blob();

    const blobUrl = window.URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = blobUrl;
    link.download =
      header.originalFileNames?.[index] || url.split("/").pop() || "download";
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.URL.revokeObjectURL(blobUrl);
  };

  if (!selectedBillDetail) return <div className="p-6">No data found</div>;

  return (
    <>
      <div className="fixed inset-0 z-50 bg-black/70 flex items-center justify-center p-0 md:p-4">
        <div
          className={`bg-white dark:bg-gray-900 flex flex-col w-full overflow-hidden shadow-lg ${
            isMobile ? "h-full" : "max-w-6xl max-h-[90vh] rounded-xl"
          }`}
        >
          <div className="px-4 sm:px-6 py-4 border-b border-brand-surface-border dark:border-zinc-700 flex items-center justify-between gap-3 shrink-0 bg-white dark:bg-gray-900">
            <div className="flex items-center gap-3 min-w-0">
              <IconButton
                onClick={() => setIsModalOpen(false)}
                className="md:hidden"
                size="small"
                aria-label="Go back"
              >
                <ArrowBackIcon />
              </IconButton>
              <h2 className={`${PAGE_TITLE_CLASS} truncate`}>Bill Details</h2>
            </div>
            <IconButton
              onClick={() => setIsModalOpen(false)}
              size="small"
              aria-label="Close"
              className="hidden md:inline-flex border border-brand-surface-border rounded-lg"
            >
              <CloseIcon fontSize="small" />
            </IconButton>
          </div>

          <ModalSectionLayout
            sections={sections}
            activeSection={activeSection}
            onSectionClick={scrollToSection}
            scrollContainerRef={scrollContainerRef}
          >
            <div
              ref={setSectionRef(BILL_SECTION_IDS.BILL_INFO)}
              id={BILL_SECTION_IDS.BILL_INFO}
              className="scroll-mt-4"
            >
              <FormSection
                title="Bill Information"
                icon={FileText}
                variantIndex={0}
              >
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <DetailField label="Bill Number">{header.billNumber}</DetailField>
                  <DetailField label="Bill Date">{header.date}</DetailField>
                  <DetailField label="Received Date">
                    {header.receivedDate}
                  </DetailField>
                  <DetailField label="Invoice Number">
                    {header.invoiceNo}
                  </DetailField>
                </div>
              </FormSection>
            </div>

            <div
              ref={setSectionRef(BILL_SECTION_IDS.SUPPLIER)}
              id={BILL_SECTION_IDS.SUPPLIER}
              className="scroll-mt-4"
            >
              <FormSection
                title="Supplier Information"
                icon={Building2}
                variantIndex={1}
              >
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <DetailField label="Supplier Name">
                    {header.supplierName}
                  </DetailField>
                  <DetailField label="Supplier Group">
                    {header.supplierGroup || "-"}
                  </DetailField>
                  <DetailField label="MSME">
                    {header.supplierMsme || "-"}
                  </DetailField>
                  <DetailField label="GSTIN" valueClassName="break-all">
                    {header.supplierGstNo || "-"}
                  </DetailField>
                </div>
              </FormSection>
            </div>

            <div
              ref={setSectionRef(BILL_SECTION_IDS.CUSTOMER)}
              id={BILL_SECTION_IDS.CUSTOMER}
              className="scroll-mt-4"
            >
              <FormSection
                title="Customer Information"
                icon={Users}
                variantIndex={2}
              >
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <DetailField label="Customer Name">
                    {header.customerName}
                  </DetailField>
                  <DetailField label="Customer Group">
                    {header.customerGroup || "-"}
                  </DetailField>
                  <DetailField label="MSME">
                    {header.customerMsme || "-"}
                  </DetailField>
                  <DetailField label="GSTIN" valueClassName="break-all">
                    {header.customerGstNo || "-"}
                  </DetailField>
                </div>
              </FormSection>
            </div>

            <div
              ref={setSectionRef(BILL_SECTION_IDS.ITEMS)}
              id={BILL_SECTION_IDS.ITEMS}
              className="scroll-mt-4"
            >
              <FormSection title="Bill Items" icon={Receipt} variantIndex={3}>
                <DataTable
                  columns={isMobile ? itemColumns.mobile : itemColumns.desktop}
                  data={items}
                  actions={false}
                  disablePagination
                  emptyMessage="No items found"
                />

                <div className="mt-6 grid grid-cols-1 sm:grid-cols-2 gap-4 text-right">
                  <div className="text-sm sm:text-base font-semibold text-brand-navy dark:text-gray-100">
                    Taxable Value: ₹
                    {formatIndianCurrency(roundUp(header.taxableValue))}
                  </div>
                  <div className="text-sm sm:text-base font-bold text-brand-primary">
                    Bill Amount: ₹
                    {formatIndianCurrency(roundUp(header.billAmount))}
                  </div>
                </div>
              </FormSection>
            </div>

            <div
              ref={setSectionRef(BILL_SECTION_IDS.TRANSPORT)}
              id={BILL_SECTION_IDS.TRANSPORT}
              className="scroll-mt-4"
            >
              <FormSection
                title="Transport & Logistics Information"
                icon={Truck}
                variantIndex={4}
              >
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <DetailField label="Transport">
                    {header.transport || "-"}
                  </DetailField>
                  <DetailField label="LR Number">
                    {header.lrNumber || "-"}
                  </DetailField>
                  <DetailField label="Remarks">
                    {header.remarks || "-"}
                  </DetailField>
                </div>
              </FormSection>
            </div>

            <div
              ref={setSectionRef(BILL_SECTION_IDS.ATTACHMENTS)}
              id={BILL_SECTION_IDS.ATTACHMENTS}
              className="scroll-mt-4"
            >
              <FormSection
                title={`Attachments (${attachmentCount})`}
                icon={Paperclip}
                variantIndex={5}
              >
                {header.publicUrls?.length ? (
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    {header.publicUrls.map((url, index) => {
                      const fileName =
                        header.originalFileNames?.[index] ||
                        url.split("/").pop() ||
                        "attachment";
                      const displayName =
                        fileName.length > 25
                          ? `${fileName.substring(0, 20)}...`
                          : fileName;

                      return (
                        <div
                          key={index}
                          className="rounded-lg border border-brand-surface-border bg-white/80 dark:bg-zinc-900/60 p-3 flex items-center gap-3 hover:shadow-sm transition-shadow"
                        >
                          <div className="flex-1 min-w-0">
                            <p
                              className="text-sm font-medium text-brand-navy dark:text-gray-100 truncate"
                              title={fileName}
                            >
                              {displayName}
                            </p>
                          </div>

                          <div className="flex gap-1">
                            <button
                              type="button"
                              onClick={() => {
                                setPreviewIndex(index);
                                setPreviewOpen(true);
                              }}
                              className="p-1.5 hover:bg-violet-100 rounded-lg text-brand-primary transition-colors"
                              title="View"
                            >
                              <VisibilityIcon className="!text-lg" />
                            </button>
                            <button
                              type="button"
                              onClick={() => handleDownload(url, index)}
                              className="p-1.5 hover:bg-green-100 rounded-lg text-green-600 transition-colors"
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
                  <div className="rounded-lg border border-brand-surface-border bg-white/70 dark:bg-zinc-900/60 px-3 py-8 text-center">
                    <VisibilityIcon className="!text-4xl text-brand-search-muted mb-2" />
                    <p className="text-brand-search-muted">No attachments</p>
                  </div>
                )}
              </FormSection>
            </div>
          </ModalSectionLayout>

          <FormFooter background="bg-white dark:bg-gray-900">
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
