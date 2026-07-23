import SupplierModal from "./SupplierModal";

const UpdateSupplierModal = ({
  supplierId,
  open,
  setOpen,
  fetchSuppliers,
}) => (
  <SupplierModal
    mode="edit"
    supplierId={supplierId}
    open={open}
    onClose={() => setOpen(false)}
    fetchSuppliers={fetchSuppliers}
  />
);

export default UpdateSupplierModal;
