import {
  Button,
  IconButton,
  Tooltip,
} from "@mui/material";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import AddIcon from "@mui/icons-material/Add";
import Autocomplete from "@mui/material/Autocomplete";
import Chip from "@mui/material/Chip";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import ContentCopyIcon from "@mui/icons-material/ContentCopy";
import { useEffect, useState } from "react";
import {
  Building2,
  MapPin,
  Phone,
  Truck,
  Landmark,
  Plus,
} from "lucide-react";
import DeleteIcon from "@mui/icons-material/Delete";
import BasicSelect from "../components/BasicSelect";
import CustomTextField from "../components/CustomTextField";
import SupplierService from "../service/SupplierService";
import TransportService from "../service/TransportService";
import { useSnackbar } from "../context/SnackbarContext";
import validate from "../validations/Validation";
import { sanitizePayload } from "../utils/sanitizePayload";
import StateAutocomplete from "../components/common/StateAutocomplete";
import FormFooter from "../components/common/FormFooter";
import FormSection from "../components/common/FormSection";
import DetailField from "../components/common/DetailField";
import {
  DETAIL_FIELD_VALUE_CLASS,
  FORM_SCROLL_AREA_CLASS,
  TRANSPORT_CHIP_CLASS,
} from "../theme/cardTheme";
import AppButton from "../components/common/AppButton";
import ConfirmDialog from "../components/common/ConfirmDialog";
import CopyDetailsModal from "../components/common/CopyDetailsModal";
import useUnsavedChanges from "../customHooks/useUnsavedChanges";
import { getSupplierFormattedText } from "../utils/copyFormatter";

const EMPTY_BANK_ACCOUNT = {
  bankName: "",
  ifscCode: "",
  branchName: "",
  accountName: "",
  accountNumber: "",
};

const mapBankAccount = (account = {}) => ({
  ...(account.id != null ? { id: account.id } : {}),
  bankName: account.bankName || "",
  ifscCode: account.ifscCode || account.ifsc || "",
  branchName: account.branchName || account.branch || "",
  accountName: account.accountName || "",
  accountNumber: account.accountNumber || "",
});

const hasBankAccountData = (account = {}) =>
  Boolean(
    account.bankName ||
      account.ifscCode ||
      account.ifsc ||
      account.branchName ||
      account.branch ||
      account.accountName ||
      account.accountNumber,
  );

const normalizeBankAccounts = (data = {}, { fallbackEmpty = true } = {}) => {
  const accounts = data.bankDetails || data.bankAccounts;

  if (Array.isArray(accounts) && accounts.length > 0) {
    const mapped = accounts.map(mapBankAccount);

    if (!fallbackEmpty) {
      return mapped.filter(hasBankAccountData);
    }

    return mapped.length ? mapped : [{ ...EMPTY_BANK_ACCOUNT }];
  }

  if (hasBankAccountData(data)) {
    return [mapBankAccount(data)];
  }

  return fallbackEmpty ? [{ ...EMPTY_BANK_ACCOUNT }] : [];
};

const mapSupplierToForm = (data) => ({
  supplierName: data.supplierName || "",
  email: data.email || "",
  groupName: data.groupName || "",
  gstNo: data.gstNo || "",
  msme: data.msme?.toUpperCase() || "",
  city: data.city || "",
  pinCode: data.pinCode || "",
  state: data.state || "",
  addressLine1: data.addressLine1 || "",
  addressLine2: data.addressLine2 || "",
  commissionRate: data.commissionRate || "",
  commissionScheme: data.commissionScheme || "",
  referenceBy: data.referenceBy || "",
  remark: data.remark || "",
  bankDetails: normalizeBankAccounts(data, { fallbackEmpty: true }),
  contacts: data.contacts?.length
    ? data.contacts
    : [{ contactPerson: "", mobileNumber: "", type: "" }],
});

const SupplierModal = ({
  mode = "view",
  supplierId,
  open = true,
  onClose,
  fetchSuppliers,
}) => {
  const isView = mode === "view";
  const readOnly = isView;
  const { showSnackbar } = useSnackbar();

  const [recordData, setRecordData] = useState(null);
  const [copyModalOpen, setCopyModalOpen] = useState(false);
  const [form, setForm] = useState({});
  const [errors, setErrors] = useState({ contacts: [{}] });
  const [allTransports, setAllTransports] = useState([]);
  const [selectedTransports, setSelectedTransports] = useState([]);
  const [isSaving, setIsSaving] = useState(false);
  const [isLoaded, setIsLoaded] = useState(false);
  const { isDirty } = useUnsavedChanges(form, !isView && open && isLoaded);
  const [confirmOpen, setConfirmOpen] = useState(false);

  useEffect(() => {
    if (!supplierId || !open) return;

    const fetchSupplier = async () => {
      try {
        const response = await SupplierService.getSupplierById(supplierId);
        const data = response.data || response;
        setRecordData(data);
        setForm(mapSupplierToForm(data));
        setSelectedTransports(data.preferredTransports || []);
        setIsLoaded(true);
      } catch (error) {
        console.error(error);
        showSnackbar(
          error?.message || "Failed to load supplier",
          "error",
        );
      }
    };

    fetchSupplier();
  }, [supplierId, open, showSnackbar]);

  useEffect(() => {
    if (!open) return;

    const fetchTransports = async () => {
      try {
        const transports = await TransportService.getAllTransports();
        setAllTransports(transports || []);
      } catch (err) {
        console.error(err);
      }
    };

    fetchTransports();
  }, [open]);

  useEffect(() => {
    if (open) return;

    setForm({});
    setRecordData(null);
    setSelectedTransports([]);
    setErrors({ contacts: [{}] });
    setIsLoaded(false);
  }, [open]);

  const handleClose = () => {
    if (!isView && isDirty()) {
      setConfirmOpen(true);
      return;
    }

    onClose?.();
  };

  const handleConfirmLeave = () => {
    setConfirmOpen(false);
    onClose?.();
  };

  const handleChange = (e) => {
    if (readOnly) return;
    const { name, value } = e.target;
    if (name === "pinCode" && !/^\d{0,6}$/.test(value)) return;
    setForm((prev) => ({
      ...prev,
      [name]: value,
    }));

    setErrors((prev) => ({
      ...prev,
      [name]: validate(name, value),
    }));
  };

  const handleContactChange = (index, e) => {
    if (readOnly) return;
    const { name, value } = e.target;
    const updatedContacts = [...form.contacts];
    updatedContacts[index][name] = value;

    setForm((prev) => ({
      ...prev,
      contacts: updatedContacts,
    }));
  };

  const handleMobileChange = (index, e) => {
    if (readOnly) return;
    const value = e.target.value;
    if (/^[0-9-\s]*$/.test(value)) {
      handleContactChange(index, e);
    }
  };

  const addContact = () => {
    setForm((prev) => ({
      ...prev,
      contacts: [
        ...(prev.contacts || []),
        { contactPerson: "", mobileNumber: "", type: "" },
      ],
    }));
  };

  const deleteContact = (index) => {
    if (index === 0) return;
    const updated = form.contacts.filter((_, i) => i !== index);
    setForm((prev) => ({
      ...prev,
      contacts: updated,
    }));
  };

  const bankDetails = form.bankDetails?.length
    ? form.bankDetails
    : [{ ...EMPTY_BANK_ACCOUNT }];

  const addBankAccount = () => {
    if (readOnly) return;

    setForm((prev) => ({
      ...prev,
      bankDetails: [
        ...(prev.bankDetails?.length ? prev.bankDetails : bankDetails),
        { ...EMPTY_BANK_ACCOUNT },
      ],
    }));
  };

  const deleteBankAccount = (indexToRemove) => {
    if (readOnly) return;

    setForm((prev) => {
      const current = prev.bankDetails?.length
        ? prev.bankDetails
        : [{ ...EMPTY_BANK_ACCOUNT }];

      if (current.length <= 1) return prev;

      return {
        ...prev,
        bankDetails: current.filter((_, index) => index !== indexToRemove),
      };
    });
  };

  const handleBankAccountChange = (index, e) => {
    if (readOnly) return;
    const { name, value } = e.target;

    setForm((prev) => {
      const current = prev.bankDetails?.length
        ? [...prev.bankDetails]
        : [{ ...EMPTY_BANK_ACCOUNT }];

      current[index] = {
        ...current[index],
        [name]: value,
      };

      return { ...prev, bankDetails: current };
    });
  };

  const handleUpdate = async () => {
    const nameError = validate("supplierName", form.supplierName);

    if (nameError) {
      showSnackbar(nameError, "error");
      return;
    }

    const filledBankDetails = (form.bankDetails || bankDetails).filter(
      hasBankAccountData,
    );

    const payload = sanitizePayload({
      ...form,
      preferredTransportIds: selectedTransports.map((t) => t.id),
      bankDetails: filledBankDetails,
    });

    try {
      setIsSaving(true);
      await SupplierService.updateSupplier(supplierId, payload);
      showSnackbar("Supplier updated successfully!", "success");
      fetchSuppliers?.();
      onClose?.();
    } catch (err) {
      showSnackbar(err.message || "Update failed", "error");
    } finally {
      setIsSaving(false);
    }
  };

  if (!open || !isLoaded) return null;

  const supplier = recordData || {};
  const viewBankAccounts = normalizeBankAccounts(supplier, {
    fallbackEmpty: false,
  });
  const fullAddress =
    [
      supplier.addressLine1,
      supplier.addressLine2,
      supplier.city ? `${supplier.city},` : "",
      supplier.state ? `${supplier.state} -` : "",
      supplier.pinCode,
    ]
      .filter(Boolean)
      .join(" ")
      .trim() || "-";

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 md:flex md:items-center md:justify-center">
      <div className="bg-white dark:bg-gray-900 w-full h-screen md:max-w-5xl md:max-h-[90vh] md:rounded-lg shadow-lg flex flex-col">
        <div className="px-3 py-2 md:p-6 border-b border-gray-300 dark:border-zinc-700 sticky top-0 bg-white dark:bg-gray-900 z-10 flex items-center gap-3">
          <IconButton
            onClick={handleClose}
            size="small"
            aria-label="Go back"
          >
            <ArrowBackIcon />
          </IconButton>

          <div className="flex items-center justify-between w-full min-w-0">
            <h2 className="text-lg md:text-xl font-semibold truncate">
              {isView ? "Supplier Details" : "Update Supplier"}
            </h2>

            {isView && (
              <Tooltip title="Copy Details">
                <IconButton
                  onClick={() => setCopyModalOpen(true)}
                  size="small"
                >
                  <ContentCopyIcon fontSize="small" />
                </IconButton>
              </Tooltip>
            )}
          </div>
        </div>

        <div
          className={`px-4 md:px-6 py-4 overflow-y-auto flex-1 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}
        >
          <FormSection title="Basic Information" icon={Building2} variantIndex={0}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {isView ? (
                <>
                  <DetailField label="Supplier Name">
                    {supplier.supplierName || "-"}
                  </DetailField>
                  <DetailField label="Email">{supplier.email || "-"}</DetailField>
                  <DetailField label="Group Name">
                    {supplier.groupName || "-"}
                  </DetailField>
                  <DetailField label="GST Number" valueClassName="break-all">
                    {supplier.gstNo || "-"}
                  </DetailField>
                  <DetailField label="MSME">{supplier.msme || "-"}</DetailField>
                  <DetailField label="Commission Scheme">
                    {supplier.commissionScheme || "-"}
                  </DetailField>
                  <DetailField label="Commission %">
                    {supplier.commissionRate ?? "-"}
                  </DetailField>
                  <DetailField label="Reference By">
                    {supplier.referenceBy || "-"}
                  </DetailField>
                </>
              ) : (
                <>
                  <CustomTextField
                    name="supplierName"
                    value={form.supplierName || ""}
                    onChange={handleChange}
                    label="Supplier Name *"
                    error={!!errors.supplierName}
                    helperText={errors.supplierName}
                  />
                  <CustomTextField
                    name="email"
                    value={form.email || ""}
                    onChange={handleChange}
                    label="Email"
                  />
                  <CustomTextField
                    name="groupName"
                    value={form.groupName || ""}
                    onChange={handleChange}
                    label="Group"
                  />
                  <CustomTextField
                    name="gstNo"
                    value={form.gstNo || ""}
                    onChange={handleChange}
                    label="GST Number"
                  />
                  <BasicSelect
                    name="msme"
                    value={form.msme || ""}
                    onChange={handleChange}
                    label="MSME"
                    options={[
                      { value: "MICRO", label: "Micro" },
                      { value: "SMALL", label: "Small" },
                      { value: "MEDIUM", label: "Medium" },
                    ]}
                  />
                  <BasicSelect
                    name="commissionScheme"
                    value={form.commissionScheme || ""}
                    onChange={handleChange}
                    label="Commission Scheme"
                    options={[
                      { value: "Fixed", label: "Fixed" },
                      { value: "Percentage", label: "Percentage" },
                      { value: "Tiered", label: "Tiered" },
                    ]}
                  />
                  <CustomTextField
                    name="commissionRate"
                    value={form.commissionRate || ""}
                    onChange={handleChange}
                    label="Commission % (Rate)"
                  />
                  <CustomTextField
                    name="referenceBy"
                    value={form.referenceBy || ""}
                    onChange={handleChange}
                    label="Reference By"
                  />
                </>
              )}
            </div>
          </FormSection>

          <FormSection title="Address Details" icon={MapPin} variantIndex={1}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {isView ? (
                <>
                  <DetailField label="Address" valueClassName="whitespace-pre-wrap">
                    {fullAddress}
                  </DetailField>
                  <DetailField label="State">{supplier.state || "-"}</DetailField>
                  <DetailField label="City">{supplier.city || "-"}</DetailField>
                  <DetailField label="Pin Code">{supplier.pinCode || "-"}</DetailField>
                </>
              ) : (
                <>
                  <CustomTextField
                    name="addressLine1"
                    value={form.addressLine1 || ""}
                    onChange={handleChange}
                    label="Address Line 1"
                  />
                  <CustomTextField
                    name="addressLine2"
                    value={form.addressLine2 || ""}
                    onChange={handleChange}
                    label="Address Line 2 (Optional)"
                  />
                  <StateAutocomplete
                    value={form.state}
                    onChange={(val) => setForm((prev) => ({ ...prev, state: val }))}
                  />
                  <CustomTextField
                    name="city"
                    value={form.city || ""}
                    onChange={handleChange}
                    label="City"
                  />
                  <CustomTextField
                    name="pinCode"
                    value={form.pinCode || ""}
                    onChange={handleChange}
                    label="Pin Code"
                  />
                </>
              )}
            </div>
          </FormSection>

          <FormSection title="Contact Information" icon={Phone} variantIndex={2}>
            {isView ? (
              supplier.contacts?.length > 0 ? (
                supplier.contacts.map((c, idx) => (
                  <div
                    key={idx}
                    className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4 last:mb-0"
                  >
                    <DetailField label="Contact Person">
                      {c.contactPerson || "-"}
                    </DetailField>
                    <DetailField label="Mobile No.">
                      {c.mobileNumber || "-"}
                    </DetailField>
                    <DetailField label="Type">{c.type || "-"}</DetailField>
                  </div>
                ))
              ) : (
                <div className="text-gray-500">No contacts available</div>
              )
            ) : (
              <>
                {form.contacts?.map((contact, index) => (
                  <div key={index} className="mb-6">
                    <div className="md:hidden border rounded-xl p-4 space-y-4 bg-gray-50">
                      <div className="flex justify-between items-center">
                        <h4 className="text-sm font-semibold text-gray-700">
                          Contact {index + 1}
                        </h4>
                        {index > 0 && (
                          <IconButton
                            size="small"
                            color="error"
                            onClick={() => deleteContact(index)}
                          >
                            <DeleteOutlineIcon fontSize="small" />
                          </IconButton>
                        )}
                      </div>
                      <CustomTextField
                        name="contactPerson"
                        value={contact.contactPerson || ""}
                        onChange={(e) => handleContactChange(index, e)}
                        label="Contact Person"
                      />
                      <CustomTextField
                        name="mobileNumber"
                        value={contact.mobileNumber || ""}
                        onChange={(e) => handleMobileChange(index, e)}
                        label="Mobile Number"
                      />
                      <CustomTextField
                        name="type"
                        value={contact.type || ""}
                        onChange={(e) => handleContactChange(index, e)}
                        label="Type"
                      />
                    </div>

                    <div className="hidden md:grid grid-cols-12 gap-4 items-start">
                      <div className="col-span-4">
                        <CustomTextField
                          name="contactPerson"
                          value={contact.contactPerson || ""}
                          onChange={(e) => handleContactChange(index, e)}
                          label="Contact Person"
                        />
                      </div>
                      <div className="col-span-4">
                        <CustomTextField
                          name="mobileNumber"
                          value={contact.mobileNumber || ""}
                          onChange={(e) => handleMobileChange(index, e)}
                          label="Mobile Number"
                        />
                      </div>
                      <div className="col-span-3">
                        <CustomTextField
                          name="type"
                          value={contact.type || ""}
                          onChange={(e) => handleContactChange(index, e)}
                          label="Type"
                        />
                      </div>
                      <div className="col-span-1 flex justify-center">
                        {index > 0 && (
                          <IconButton
                            size="small"
                            color="error"
                            onClick={() => deleteContact(index)}
                          >
                            <DeleteOutlineIcon fontSize="small" />
                          </IconButton>
                        )}
                      </div>
                    </div>
                  </div>
                ))}

                <Button
                  variant="outlined"
                  startIcon={<AddIcon />}
                  onClick={addContact}
                >
                  Add Contact
                </Button>
              </>
            )}
          </FormSection>

          <FormSection title="Preferred Transports" icon={Truck} variantIndex={3}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {isView ? (
                <div>
                  <label className="block text-sm font-medium mb-1 text-gray-700 dark:text-gray-300">
                    Preferred Transport
                  </label>
                  <div
                    className={`rounded px-3 py-2 text-sm min-h-9 flex flex-wrap gap-2 items-center border ${DETAIL_FIELD_VALUE_CLASS}`}
                  >
                    {supplier.preferredTransports?.length > 0 ? (
                      supplier.preferredTransports.map((transport, idx) => (
                        <span
                          key={idx}
                          className={`px-3 py-1 rounded-full text-xs ${TRANSPORT_CHIP_CLASS}`}
                        >
                          {transport.name || "Unknown"}
                        </span>
                      ))
                    ) : (
                      <span className="text-gray-500 text-sm">No transports</span>
                    )}
                  </div>
                </div>
              ) : (
                <Autocomplete
                  multiple
                  options={allTransports}
                  value={selectedTransports}
                  isOptionEqualToValue={(o, v) => o.id === v.id}
                  getOptionLabel={(o) => o.name}
                  onChange={(e, values) => setSelectedTransports(values)}
                  renderTags={(value, getTagProps) =>
                    value.map((option, index) => (
                      <Chip
                        key={option.id}
                        label={option.name}
                        {...getTagProps({ index })}
                      />
                    ))
                  }
                  renderInput={(params) => (
                    <CustomTextField {...params} label="Preferred Transports" />
                  )}
                />
              )}

              {isView ? (
                <DetailField label="Remark">{supplier.remark || "-"}</DetailField>
              ) : (
                <CustomTextField
                  name="remark"
                  value={form.remark || ""}
                  onChange={handleChange}
                  label="Remarks (optional)"
                  multiline
                  rows={0}
                />
              )}
            </div>
          </FormSection>

          <FormSection title="Bank Details" icon={Landmark} variantIndex={4}>
            {isView ? (
              viewBankAccounts.length > 0 ? (
                viewBankAccounts.map((account, index) => (
                  <div
                    key={index}
                    className="border border-gray-200 rounded-lg p-4 sm:p-5 bg-gray-50 mb-4 last:mb-0 dark:bg-zinc-800/50 dark:border-zinc-700"
                  >
                    <div className="flex justify-between items-center mb-4">
                      <h4 className="font-medium text-gray-700 dark:text-gray-200">
                        Bank Account {index + 1}
                      </h4>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <DetailField label="Bank Name">
                        {account.bankName || "-"}
                      </DetailField>
                      <DetailField label="IFSC Code">
                        {account.ifscCode || "-"}
                      </DetailField>
                      <DetailField label="Branch Name">
                        {account.branchName || "-"}
                      </DetailField>
                      <DetailField label="Account Holder Name">
                        {account.accountName || "-"}
                      </DetailField>
                      <DetailField label="Account Number">
                        {account.accountNumber || "-"}
                      </DetailField>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-gray-500">No bank details available</div>
              )
            ) : (
              <>
                {bankDetails.map((account, index) => (
                  <div
                    key={index}
                    className="border border-gray-200 rounded-lg p-4 sm:p-5 bg-gray-50 mb-4 dark:bg-zinc-800/50 dark:border-zinc-700"
                  >
                    <div className="flex justify-between items-center mb-4">
                      <h4 className="font-medium text-gray-700 dark:text-gray-200">
                        Bank Account {index + 1}
                      </h4>

                      {bankDetails.length > 1 && (
                        <IconButton
                          color="error"
                          size="small"
                          onClick={() => deleteBankAccount(index)}
                          aria-label={`Delete bank account ${index + 1}`}
                        >
                          <DeleteIcon fontSize="small" />
                        </IconButton>
                      )}
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <CustomTextField
                        name="bankName"
                        value={account.bankName || ""}
                        onChange={(e) => handleBankAccountChange(index, e)}
                        label="Bank Name"
                      />
                      <CustomTextField
                        name="ifscCode"
                        value={account.ifscCode || ""}
                        onChange={(e) => handleBankAccountChange(index, e)}
                        label="IFSC Code"
                      />
                      <CustomTextField
                        name="branchName"
                        value={account.branchName || ""}
                        onChange={(e) => handleBankAccountChange(index, e)}
                        label="Branch Name"
                      />
                      <CustomTextField
                        name="accountName"
                        value={account.accountName || ""}
                        onChange={(e) => handleBankAccountChange(index, e)}
                        label="Account Holder Name"
                      />
                      <CustomTextField
                        name="accountNumber"
                        value={account.accountNumber || ""}
                        onChange={(e) => handleBankAccountChange(index, e)}
                        label="Account Number"
                        inputProps={{ inputMode: "numeric" }}
                      />
                    </div>
                  </div>
                ))}

                <div className="flex justify-end mt-2">
                  <AppButton
                    type="primary"
                    onClick={addBankAccount}
                    startIcon={<Plus className="h-4 w-4" />}
                  >
                    <span className="sm:hidden">Add</span>
                    <span className="hidden sm:inline">
                      Add More Bank Accounts
                    </span>
                  </AppButton>
                </div>
              </>
            )}
          </FormSection>
        </div>

        <FormFooter>
          {!isView && (
            <AppButton
              type="primary"
              loading={isSaving}
              onClick={handleUpdate}
              sx={{ minWidth: "140px" }}
            >
              Update Supplier
            </AppButton>
          )}

          <AppButton
            type="cancel"
            disabled={!isView && isSaving}
            onClick={handleClose}
          >
            Cancel
          </AppButton>
        </FormFooter>

        {isView && copyModalOpen && recordData && (
          <CopyDetailsModal
            open={copyModalOpen}
            onClose={() => setCopyModalOpen(false)}
            title="Copy Supplier Details"
            formattedText={getSupplierFormattedText(recordData)}
            splitBankCopy
          />
        )}

        {!isView && (
          <ConfirmDialog
            open={confirmOpen}
            onConfirm={handleConfirmLeave}
            onCancel={() => setConfirmOpen(false)}
          />
        )}
      </div>
    </div>
  );
};

export default SupplierModal;
