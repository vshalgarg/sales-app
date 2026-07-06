import CustomerModal from "./CustomerModal";

const CustomerDetail = ({ customerId, setModalOpen }) => (
  <CustomerModal
    mode="view"
    customerId={customerId}
    open
    onClose={() => setModalOpen(false)}
  />
);

export default CustomerDetail;
