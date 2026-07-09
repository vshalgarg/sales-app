import { useMemo } from "react";
import useResponsive from "../customHooks/useResponsive";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import CloseIcon from "@mui/icons-material/Close";
import { IconButton } from "@mui/material";
import AppButton from "../components/common/AppButton";
import FormFooter from "../components/common/FormFooter";
import FormSection from "../components/common/FormSection";
import DetailField from "../components/common/DetailField";
import ModalSectionLayout from "../components/common/ModalSectionLayout";
import {
  CREDIT_SECTION_IDS,
  getCreditModalSections,
} from "../components/common/creditModalSections";
import { useModalSectionNav } from "../customHooks/useModalSectionNav";
import { formatIndianCurrency } from "../utils/currencyUtils";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";
import { ClipboardList, FileText, Link2, Users } from "lucide-react";

const CreditDetail = ({ selectedCreditDetail, setIsModalOpen }) => {
  const { isMobile } = useResponsive();

  const sections = useMemo(() => getCreditModalSections(), []);
  const sectionIds = useMemo(
    () => sections.map((section) => section.id),
    [sections],
  );

  const { activeSection, scrollToSection, scrollContainerRef, setSectionRef } =
    useModalSectionNav(sectionIds, { enabled: !!selectedCreditDetail });

  if (!selectedCreditDetail) return null;

  return (
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
            <h2 className={`${PAGE_TITLE_CLASS} truncate`}>Credit Details</h2>
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
            ref={setSectionRef(CREDIT_SECTION_IDS.TRANSACTION)}
            id={CREDIT_SECTION_IDS.TRANSACTION}
            className="scroll-mt-4"
          >
            <FormSection
              title="Transaction Details"
              icon={FileText}
              variantIndex={0}
            >
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <DetailField label="Invoice Number">
                  {selectedCreditDetail.billNumber}
                </DetailField>
                <DetailField label="Transaction Date">
                  {selectedCreditDetail.date}
                </DetailField>
                <DetailField label="Payment Type">
                  {selectedCreditDetail.paymentType}
                </DetailField>
                <DetailField label="Received Amount">
                  {formatIndianCurrency(selectedCreditDetail.receivedAmount)}
                </DetailField>
              </div>
            </FormSection>
          </div>

          <div
            ref={setSectionRef(CREDIT_SECTION_IDS.PARTY)}
            id={CREDIT_SECTION_IDS.PARTY}
            className="scroll-mt-4"
          >
            <FormSection
              title="Party Information"
              icon={Users}
              variantIndex={1}
            >
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <DetailField label="Supplier Name">
                  {selectedCreditDetail.supplierName}
                </DetailField>
                <DetailField label="Customer Name">
                  {selectedCreditDetail.customerName}
                </DetailField>
              </div>
            </FormSection>
          </div>

          <div
            ref={setSectionRef(CREDIT_SECTION_IDS.REFERENCE)}
            id={CREDIT_SECTION_IDS.REFERENCE}
            className="scroll-mt-4"
          >
            <FormSection
              title="Reference Details"
              icon={Link2}
              variantIndex={2}
            >
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <DetailField label="Reference Number">
                  {selectedCreditDetail.referenceNumber}
                </DetailField>
                <DetailField label="Reference Date">
                  {selectedCreditDetail.referenceDate}
                </DetailField>
                <DetailField label="Slip Number">
                  {selectedCreditDetail.slipNumber}
                </DetailField>
              </div>
            </FormSection>
          </div>

          <div
            ref={setSectionRef(CREDIT_SECTION_IDS.MISC)}
            id={CREDIT_SECTION_IDS.MISC}
            className="scroll-mt-4"
          >
            <FormSection
              title="Miscellaneous"
              icon={ClipboardList}
              variantIndex={3}
            >
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <DetailField label="Draw Type">
                  {selectedCreditDetail.drawType}
                </DetailField>
                <DetailField label="Remarks">
                  {selectedCreditDetail.remark}
                </DetailField>
              </div>
            </FormSection>
          </div>
        </ModalSectionLayout>

        <FormFooter background="bg-white dark:bg-gray-900">
          <AppButton
            type="primary"
            onClick={() => setIsModalOpen(false)}
            sx={{ minWidth: "130px" }}
          >
            Close
          </AppButton>
        </FormFooter>
      </div>
    </div>
  );
};

export default CreditDetail;
