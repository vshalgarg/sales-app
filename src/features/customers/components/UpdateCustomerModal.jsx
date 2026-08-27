import CustomerModal from "./CustomerModal";

const UpdateCustomerModal = ({
  customerId,
  open,
  setOpen,
  fetchCustomers,
}) => (
  <CustomerModal
    mode="edit"
    customerId={customerId}
    open={open}
    onClose={() => setOpen(false)}
    fetchCustomers={fetchCustomers}
  />
);

export default UpdateCustomerModal;
