import { useEffect, useState, useCallback } from "react";
import { MapPin, MapPinned, Phone, Receipt, Plus } from "lucide-react";
import { useSnackbar } from "../context/SnackbarContext";
import CustomerService from "../service/CustomerService";
import AddNewCustomer from "../modals/AddNewCustomer";
import CustomerDetail from "../modals/CustomerDetail";
import UniversalSearch from "../components/UniversalSearch";
import EntityCardGrid from "./common/EntityCardGrid";
import useResponsive from "../customHooks/useResponsive";
import DeleteConfirmModal from "./common/DeleteConfirmModal";
import CopyDetailsModal from "./common/CopyDetailsModal";
import UpdateCustomerModal from "../modals/UpdateCustomerModal";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";
import { getCustomerFormattedText } from "../utils/copyFormatter";
import { IconButton, Tooltip } from "@mui/material";

const CUSTOMER_CARD_FIELDS = [
  { label: "GST", key: "customerGstNo", icon: Receipt },
  { label: "City", key: "city", icon: MapPin },
  {
    label: "Mobile",
    key: "mobile",
    icon: Phone,
    getValue: (customer) => customer.contacts?.[0]?.mobileNumber,
  },
  { label: "Address", key: "address", icon: MapPinned },
];

export default function CustomerDashboard() {
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [selectedCustomer, setSelectedCustomer] = useState(null);
  const [open, setOpen] = useState(false);
  const [modalOpen, setModalOpen] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(6);
  const [customers, setCustomers] = useState([]);
  const [query, setQuery] = useState("");
  const { showSnackbar } = useSnackbar();
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [customerToDelete, setCustomerToDelete] = useState(null);
  const [totalItems, setTotalItems] = useState(0);
  const { isMobile } = useResponsive();
  const [openEdit, setOpenEdit] = useState(false);
  const [editingCustomerId, setEditingCustomerId] = useState(null);
  const [copyModalOpen, setCopyModalOpen] = useState(false);
  const [customerToCopy, setCustomerToCopy] = useState(null);

  const [form, setForm] = useState({
    customerName: "",
    email: "",
    customerGroup: "",
    customerGstNo: "",
    customerMsme: "",
    referencedBy: "",
    addressLine1: "",
    addressLine2: "",
    state: "",
    city: "",
    pinCode: "",
    contacts: [{ contactPerson: "", mobileNumber: "", type: "" }],
    preferredTransportIds: [],
    remark: "",
    bankName: "",
    ifsc: "",
    branch: "",
    accountName: "",
    accountNumber: "",
  });

  const handleCopyDetails = async (customer) => {
    try {
      const customerData = await CustomerService.getCustomerById(customer.id);
      setCustomerToCopy(customerData.data || customerData);
      setCopyModalOpen(true);
    } catch (error) {
      console.error("Error fetching customer details:", error);
      showSnackbar(error.message, "error");
    }
  };

  const buildCustomerCardProps = (customer) => ({
    code: customer.code,
    title: customer.customerName,
    fields: CUSTOMER_CARD_FIELDS.map(({ label, key, icon, getValue }) => ({
      label,
      icon,
      value: getValue ? getValue(customer) : customer[key],
    })),
    onView: () => {
      setSelectedCustomer(customer);
      setModalOpen(true);
    },
    onEdit: () => {
      setEditingCustomerId(customer.id);
      setOpenEdit(true);
    },
    onCopy: () => handleCopyDetails(customer),
    onDelete: () => {
      setCustomerToDelete(customer);
      setDeleteModalOpen(true);
    },
  });

  const fetchCustomers = useCallback(
    async (uiPage = 1) => {
      const backendPage = uiPage - 1;
      try {
        const data = await CustomerService.getCustomers(
          backendPage,
          rowsPerPage,
        );
        setCustomers(data.content || []);
        setTotalPages(data.totalPages || 0);
        setTotalItems(data.totalElements || 0);
        setCurrentPage(uiPage);
        setIsSearchActive(false);
      } catch (error) {
        setCustomers([]);
        setTotalPages(0);
        setTotalItems(0);
        showSnackbar(error.message, "error");
      }
    },
    [rowsPerPage],
  );

  const handleSearchResult = (response, searchQuery, page = 1) => {
    const results = response.content || [];
    setCustomers(results);
    setTotalPages(response.totalPages || 0);
    setTotalItems(response.totalElements || 0);
    setIsSearchActive(searchQuery.trim() !== "");
    setCurrentPage(page);
  };

  const handleRowsPerPageChange = async (newSize) => {
    setRowsPerPage(newSize);
    setCurrentPage(1);

    if (isSearchActive && query.trim()) {
      try {
        const response = await CustomerService.searchCustomers(
          query,
          0,
          newSize,
        );
        handleSearchResult(response, query, 1);
      } catch (error) {
        showSnackbar(error.message, "error");
      }
    }
  };

  const handleChangePage = async (newPage) => {
    if (newPage < 1 || (totalPages > 0 && newPage > totalPages)) return;

    setCurrentPage(newPage);

    if (isSearchActive && query.trim()) {
      try {
        const backendPage = newPage - 1;
        const response = await CustomerService.searchCustomers(
          query,
          backendPage,
          rowsPerPage,
        );
        handleSearchResult(response, query, newPage);
      } catch (error) {
        console.error("Error fetching search page:", error);
        showSnackbar(error.message, "error");
      }
    } else {
      fetchCustomers(newPage);
    }
  };

  const handleClearSearch = useCallback(() => {
    setQuery("");
    setIsSearchActive(false);
    fetchCustomers(1);
  }, [fetchCustomers]);

  useEffect(() => {
    if (!query.trim() && isSearchActive) {
      handleClearSearch();
    }
  }, [query, isSearchActive, handleClearSearch]);

  useEffect(() => {
    fetchCustomers(1);
  }, [fetchCustomers]);

  const handleDelete = async () => {
    if (!customerToDelete) return;
    try {
      const response = await CustomerService.deleteCustomer(
        customerToDelete.code,
      );
      showSnackbar(response.message, "success");
      fetchCustomers(currentPage);
    } catch (error) {
      console.error("Error deleting customer:", error);
      showSnackbar(error.message, "error");
    } finally {
      setDeleteModalOpen(false);
      setCustomerToDelete(null);
    }
  };

  return (
    <div className="text-gray-900 dark:text-gray-100 flex flex-col h-full">
      <div>
        <div className="flex justify-between items-center mt-2 mb-3 gap-3">
          <div className="flex gap-2">
            <h2 className={PAGE_TITLE_CLASS}>
              {isMobile ? "Customer" : "Customer Overview"}
            </h2>
            <Tooltip title="Add customer">
              <span>
                <IconButton
                  onClick={() => setOpen(true)}
                  size="medium"
                  className="!bg-brand-primary hover:!bg-brand-primary-dark"
                >
                  <Plus className="h-5 w-5 text-white" />
                </IconButton>
              </span>
            </Tooltip>
          </div>

          <UniversalSearch
            placeholder="Search customers..."
            query={query}
            setQuery={setQuery}
            searchFn={CustomerService.searchCustomers}
            onResult={handleSearchResult}
            onClear={handleClearSearch}
            suggestionKey="customerName"
            pageSize={rowsPerPage}
            showSuggestions={false}
          />
        </div>
      </div>

      <div className="flex-1 min-h-0">
        <EntityCardGrid
          items={customers}
          buildCardProps={buildCustomerCardProps}
          emptyMessage="No customers found"
          page={currentPage}
          totalCount={totalItems}
          rowsPerPage={rowsPerPage}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleRowsPerPageChange}
          entityLabel="customers"
        />
      </div>

      {modalOpen && selectedCustomer && (
        <CustomerDetail
          customerId={selectedCustomer?.id}
          setModalOpen={setModalOpen}
        />
      )}

      {open && (
        <AddNewCustomer
          open={open}
          form={form}
          setOpen={setOpen}
          setForm={setForm}
          fetchCustomers={fetchCustomers}
        />
      )}

      {openEdit && (
        <UpdateCustomerModal
          customerId={editingCustomerId}
          open={openEdit}
          setOpen={setOpenEdit}
          fetchCustomers={() => fetchCustomers(currentPage)}
        />
      )}

      <DeleteConfirmModal
        open={deleteModalOpen}
        title="Delete Customer"
        message={
          <>
            Are you sure you want to permanently delete{" "}
            <b>{customerToDelete?.customerName}</b>? This action cannot be
            undone.
          </>
        }
        confirmText="Delete"
        cancelText="Cancel"
        onClose={() => {
          setDeleteModalOpen(false);
          setCustomerToDelete(null);
        }}
        onConfirm={handleDelete}
      />

      {copyModalOpen && (
        <CopyDetailsModal
          open={copyModalOpen}
          onClose={() => setCopyModalOpen(false)}
          title="Copy Customer Details"
          formattedText={getCustomerFormattedText(customerToCopy)}
          splitBankCopy
        />
      )}
    </div>
  );
}
