import DownloadIcon from "@mui/icons-material/Download";
import VisibilityIcon from "@mui/icons-material/Visibility";
import dayjs from "dayjs";
import { useState } from "react";
import ImagePreviewDialog from "@/components/ImagePreviewDialog";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import CloseIcon from "@mui/icons-material/Close";
import { IconButton } from "@mui/material";
import AppButton from "@/components/AppButton";
import FormFooter from "@/components/FormFooter";
import FormSection from "@/components/FormSection";
import DetailField from "@/components/DetailField";
import useResponsive from "@/hooks/useResponsive";
import { PAGE_TITLE_CLASS } from "@/theme/appTheme";
import { FORM_SCROLL_AREA_CLASS } from "@/theme/cardTheme";
import { FileText, Paperclip } from "lucide-react";

const PurchaseView = ({ data, open, onClose }) => {
  const [previewOpen, setPreviewOpen] = useState(false);
  const [previewIndex, setPreviewIndex] = useState(0);
  const { isMobile } = useResponsive();

  if (!open) return null;

  const images = data?.supplier?.images || [];

  const handleDownload = async (url, fileName) => {
    const response = await fetch(url);
    const blob = await response.blob();

    const blobUrl = window.URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = blobUrl;
    link.download = fileName || url.split("/").pop() || "download";
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.URL.revokeObjectURL(blobUrl);
  };

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
                onClick={onClose}
                className="md:hidden"
                size="small"
                aria-label="Go back"
              >
                <ArrowBackIcon />
              </IconButton>
              <h2 className={`${PAGE_TITLE_CLASS} truncate`}>Purchase Details</h2>
            </div>
            <IconButton
              onClick={onClose}
              size="small"
              aria-label="Close"
              className="hidden md:inline-flex border border-brand-surface-border rounded-lg"
            >
              <CloseIcon fontSize="small" />
            </IconButton>
          </div>

          <div
            className={`flex-1 min-h-0 overflow-y-auto p-4 md:p-6 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}
          >
            <FormSection
              title="Basic Information"
              icon={FileText}
              variantIndex={0}
            >
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <DetailField label="Date">
                  {data.date ? dayjs(data.date).format("DD-MM-YYYY") : "-"}
                </DetailField>
                <DetailField label="Staff">{data.staffName || "-"}</DetailField>
                <DetailField label="Customer">
                  {data.customerName || "-"}
                </DetailField>
                <DetailField label="Supplier">
                  {data.supplier?.supplierName || "-"}
                </DetailField>
                <DetailField label="Remarks">
                  {data.remarks != null ? data.remarks : "-"}
                </DetailField>
              </div>
            </FormSection>

            <FormSection
              title={`Attachments (${images.length})`}
              icon={Paperclip}
              variantIndex={1}
            >
              {images.length ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {images.map((img, index) => {
                    const url = img.url;
                    const fileName =
                      img.fileName || url.split("/").pop() || "attachment";
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
                            onClick={() => handleDownload(url, fileName)}
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

          <FormFooter background="bg-white dark:bg-gray-900">
            <AppButton
              type="primary"
              onClick={onClose}
              sx={{ minWidth: "140px" }}
            >
              Close
            </AppButton>
          </FormFooter>
        </div>
      </div>

      <ImagePreviewDialog
        open={previewOpen}
        images={images.map((i) => i.url)}
        index={previewIndex}
        onClose={() => setPreviewOpen(false)}
        onChangeIndex={setPreviewIndex}
      />
    </>
  );
};

export default PurchaseView;
