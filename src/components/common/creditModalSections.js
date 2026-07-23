import { ClipboardList, FileText, Link2, Users } from "lucide-react";

export const CREDIT_SECTION_IDS = {
  TRANSACTION: "transaction-details",
  PARTY: "party-information",
  REFERENCE: "reference-details",
  MISC: "miscellaneous",
};

export const getCreditModalSections = () => [
  {
    id: CREDIT_SECTION_IDS.TRANSACTION,
    label: "Transaction Details",
    icon: FileText,
  },
  {
    id: CREDIT_SECTION_IDS.PARTY,
    label: "Party Information",
    icon: Users,
  },
  {
    id: CREDIT_SECTION_IDS.REFERENCE,
    label: "Reference Details",
    icon: Link2,
  },
  {
    id: CREDIT_SECTION_IDS.MISC,
    label: "Miscellaneous",
    icon: ClipboardList,
  },
];
