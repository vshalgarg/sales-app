import {
  Building2,
  FileText,
  Paperclip,
  Receipt,
  Truck,
  Users,
} from "lucide-react";

export const BILL_SECTION_IDS = {
  BILL_INFO: "bill-info",
  SUPPLIER: "supplier-info",
  CUSTOMER: "customer-info",
  ITEMS: "bill-items",
  TRANSPORT: "transport-info",
  ATTACHMENTS: "attachments",
};

export const getBillModalSections = (attachmentCount = 0) => [
  {
    id: BILL_SECTION_IDS.BILL_INFO,
    label: "Bill Information",
    icon: FileText,
  },
  {
    id: BILL_SECTION_IDS.SUPPLIER,
    label: "Supplier Information",
    icon: Building2,
  },
  {
    id: BILL_SECTION_IDS.CUSTOMER,
    label: "Customer Information",
    icon: Users,
  },
  {
    id: BILL_SECTION_IDS.ITEMS,
    label: "Bill Items",
    icon: Receipt,
  },
  {
    id: BILL_SECTION_IDS.TRANSPORT,
    label: "Transport & Logistics",
    icon: Truck,
  },
  {
    id: BILL_SECTION_IDS.ATTACHMENTS,
    label: `Attachments (${attachmentCount})`,
    icon: Paperclip,
  },
];
