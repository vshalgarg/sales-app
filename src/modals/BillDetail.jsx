import DataTable from "../components/DataTable";
import useResponsive from "../customHooks/useResponsive";

const BillDetail = ({ selectedBillDetail, setIsModalOpen }) => {


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


  if (!selectedBillDetail) return null;

  const { items = [], ...header } = selectedBillDetail;

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


 return (
    <div className="fixed inset-0 z-50 bg-black bg-opacity-70 flex items-center justify-center">
      {/* Modal container */}
      <div
        className={`
          bg-white dark:bg-gray-900 flex flex-col
          w-full ${isMobile ? "h-full rounded-none" : "max-w-6xl max-h-[90vh] rounded-lg"}
        `}
      >
        {/* Header */}
        <div className="px-4 sm:px-6 py-4 border-b flex justify-between items-center">
          <h2 className="text-lg sm:text-2xl font-semibold">Bill Details</h2>
          <button
            onClick={() => setIsModalOpen(false)}
            className="text-2xl text-gray-500 hover:text-gray-700"
          >
            ×
          </button>
        </div>

        {/* Body */}
        <div className="flex-1 overflow-y-auto px-4 sm:px-6 py-4 space-y-8">
          {/* Bill Information */}
          <Section title="Bill Information">
            <InfoGrid cols="md:grid-cols-2">
              <Info label="Bill Number" value={header.billNumber} />
              <Info label="Bill Date" value={header.date} />
              <Info label="Received Date" value={header.receivedDate} />
              <Info label="Order" value={header.order} />
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
              <div>Taxable Value: ₹{header.taxableValue?.toFixed(2) || "0.00"}</div>
              <div>Bill Amount: ₹{header.billAmount?.toFixed(2) || "0.00"}</div>
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
        </div>

        {/* Footer */}
        <div className="px-4 sm:px-6 py-4 border-t flex justify-end sticky bottom-0 bg-white">
          <button
            onClick={() => setIsModalOpen(false)}
            className="w-full sm:w-auto px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};

export default BillDetail;