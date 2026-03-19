import useResponsive from "../customHooks/useResponsive";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import { IconButton } from "@mui/material";
import AppButton from "../components/common/AppButton";
import FormFooter from "../components/common/FormFooter";

const CreditDetail = ({ selectedCreditDetail, setIsModalOpen }) => {

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

  if (!selectedCreditDetail) return null;

  const { isMobile } = useResponsive();

  return (
    <div className="fixed inset-0 z-50 bg-black bg-opacity-70 flex items-center justify-center">
      <div
        className={`
          bg-white dark:bg-gray-900 flex flex-col
          w-full
          ${isMobile ? "h-full rounded-none" : "max-w-4xl max-h-[90vh] rounded-lg"}
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
            Credit Details
          </h2>
        </div>

        {/* Body */}
        <div className="flex-1 overflow-y-auto px-4 sm:px-6 py-4 space-y-8">

          {/* Transaction Details */}
          <Section title="Transaction Details">
            <InfoGrid cols="md:grid-cols-2">
              <Info label="Invoice Number" value={selectedCreditDetail.billNumber} />
              <Info label="Transaction Date" value={selectedCreditDetail.date} />
              <Info label="Payment Type" value={selectedCreditDetail.paymentType} />
              <Info label="Received Amount" value={selectedCreditDetail.receivedAmount} />
            </InfoGrid>
          </Section>

          {/* Party Information */}
          <Section title="Party Information">
            <InfoGrid cols="md:grid-cols-2">
              <Info label="Supplier Name" value={selectedCreditDetail.supplierName} />
              <Info label="Customer Name" value={selectedCreditDetail.customerName} />
            </InfoGrid>
          </Section>

          {/* Reference Details */}
          <Section title="Reference Details">
            <InfoGrid cols="md:grid-cols-3">
              <Info
                label="Reference Number"
                value={selectedCreditDetail.referenceNumber}
              />
              <Info
                label="Reference Date"
                value={selectedCreditDetail.referenceDate}
              />
              <Info
                label="Slip Number"
                value={selectedCreditDetail.slipNumber}
              />
            </InfoGrid>
          </Section>

          {/* Miscellaneous */}
          <Section title="Miscellaneous">
            <InfoGrid cols="md:grid-cols-2">
              <Info label="Draw Type" value={selectedCreditDetail.drawType} />
              <Info label="Remarks" value={selectedCreditDetail.remark} />
            </InfoGrid>
          </Section>
        </div>

        {/* Footer */}
        <FormFooter background="bg-white">

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
