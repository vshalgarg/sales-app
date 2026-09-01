import SupplierModal from "./SupplierModal";

const SupplierDetail = ({ supplierId, setIsModalOpen }) => (
  <SupplierModal
    mode="view"
    supplierId={supplierId}
    open
    onClose={() => setIsModalOpen(false)}
  />
);

export default SupplierDetail;
