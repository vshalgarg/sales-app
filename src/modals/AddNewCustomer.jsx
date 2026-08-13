import { Button, IconButton, Autocomplete, Chip } from "@mui/material";
import { useState, useEffect } from "react";
import BasicSelect from "../components/BasicSelect";
import CustomTextField from "../components/CustomTextField";
import AddIcon from "@mui/icons-material/Add";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import DeleteIcon from "@mui/icons-material/Delete";
import CustomerService from "../service/CustomerService";
import { useSnackbar } from "../context/SnackbarContext";
import validate from "../validations/Validation";
import TransportService from "../service/TransportService";
import { sanitizePayload } from "../utils/sanitizePayload";
import StateAutocomplete from "../components/common/StateAutocomplete";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import FormFooter from "../components/common/FormFooter";
import FormSection from "../components/common/FormSection";
import { FORM_SCROLL_AREA_CLASS } from "../theme/cardTheme";
import AppButton from "../components/common/AppButton";
import useUnsavedChanges from "../customHooks/useUnsavedChanges";
import ConfirmDialog from "../components/common/ConfirmDialog";
import {
  Building2,
  MapPin,
  Phone,
  Truck,
  Landmark,
  Plus,
} from "lucide-react";

const EMPTY_BANK_ACCOUNT = {
  bankName: "",
  ifscCode: "",
  branchName: "",
  accountName: "",
  accountNumber: "",
};

const AddNewCustomer = ({ form, open, setOpen, setForm, fetchCustomers }) => {
  const [isSaving, setIsSaving] = useState(false);
  const [errors, setErrors] = useState({
    contacts: [{}],
  });
  const { showSnackbar } = useSnackbar();
  const [allTransports, setAllTransports] = useState([]);
  const [transportLoading, setTransportLoading] = useState(false);
  const [selectedTransports, setSelectedTransports] = useState([]);
  const { isDirty } = useUnsavedChanges(form, open);
  const [confirmOpen, setConfirmOpen] = useState(false);

  useEffect(() => {
    const loadTransports = async () => {
      try {
        setTransportLoading(true);
        const data = await TransportService.getAllTransports();
        setAllTransports(data || []);
      } catch (error) {
        showSnackbar(error.message, "error");
      } finally {
        setTransportLoading(false);
      }
    };
    loadTransports();
  }, [showSnackbar]);

  const handleFormChange = (e) => {
    const { name, value } = e.target;

    if (name === "pinCode") {
      if (!/^\d{0,6}$/.test(value)) return;

      setForm((prev) => ({ ...prev, pinCode: value }));
      setErrors((prev) => ({ ...prev, pinCode: validate("pinCode", value) }));
      return;
    }

    setForm((prev) => ({
      ...prev,
      [name]: value,
    }));
    setErrors((prev) => ({ ...prev, [name]: validate(name, value) }));
  };

  const handleClose = () => {
    if (isDirty()) {
      setConfirmOpen(true);
      return;
    }

    resetForm();
    setOpen(false);
  };

  const handleConfirmLeave = () => {
    setConfirmOpen(false);
    resetForm();
    setOpen(false);
  };

  const handleStay = () => {
    setConfirmOpen(false);
  };

  const addContact = () => {
    setForm({
      ...form,
      contacts: [
        ...form.contacts,
        { contactPerson: "", mobileNumber: "", type: "" },
      ],
    });

    setErrors((prevErrors) => ({
      ...prevErrors,
      contacts: [...(prevErrors.contacts || []), {}],
    }));
  };

  const deleteContact = (index) => {
    if (index === 0) return;

    const updatedContacts = form.contacts.filter((_, i) => i !== index);
    const updatedErrors = errors.contacts.filter((_, i) => i !== index);

    setForm((prev) => ({
      ...prev,
      contacts: updatedContacts,
    }));

    setErrors((prev) => ({
      ...prev,
      contacts: updatedErrors,
    }));
  };

  const handleContactChange = (index, e) => {
    const { name, value } = e.target;

    const newContacts = [...form.contacts];
    newContacts[index][name] = value;
    setForm({ ...form, contacts: newContacts });

    const errorMsg = validate(name, value);
    const updatedContactErrors = [...errors.contacts];
    if (!updatedContactErrors[index]) updatedContactErrors[index] = {};
    updatedContactErrors[index][name] = errorMsg;

    setErrors((prev) => ({
      ...prev,
      contacts: updatedContactErrors,
    }));
  };

  const bankDetails = form.bankDetails?.length
    ? form.bankDetails
    : [{ ...EMPTY_BANK_ACCOUNT }];

  const addBankAccount = () => {
    setForm((prev) => ({
      ...prev,
      bankDetails: [
        ...(prev.bankDetails || bankDetails),
        { ...EMPTY_BANK_ACCOUNT },
      ],
    }));
  };

  const deleteBankAccount = (indexToRemove) => {
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

  const handleAddCustomer = async ({ closeAfterSave }) => {
    if (isSaving) return;

    const nameError = validate("customerName", form.customerName);

    if (nameError) {
      setErrors((prev) => ({
        ...prev,
        customerName: nameError,
      }));

      showSnackbar(nameError, "error");
      return;
    }

    const filledBankDetails = (form.bankDetails || bankDetails).filter(
      (account) =>
        account.bankName ||
        account.ifscCode ||
        account.branchName ||
        account.accountName ||
        account.accountNumber,
    );

    const payload = sanitizePayload({
      ...form,
      preferredTransportIds: selectedTransports.map((t) => t.id),
      bankDetails: filledBankDetails,
    });

    try {
      setIsSaving(true);

      const response = await CustomerService.saveCustomer(payload);

      if (!response || response.error) {
        showSnackbar(response?.message || "Failed to save customer", "error");
        return;
      }

      showSnackbar("Customer added successfully", "success");
      fetchCustomers();
      resetForm();

      if (closeAfterSave) {
        setOpen(false);
      }
    } catch (error) {
      showSnackbar(error.message, "error");
    } finally {
      setIsSaving(false);
    }
  };

  const resetForm = () => {
    setForm({
      ...Object.fromEntries(
        Object.keys(form).map((key) => [
          key,
          Array.isArray(form[key]) ? [] : "",
        ]),
      ),
      contacts: [{ contactPerson: "", mobileNumber: "", type: "" }],
      bankDetails: [{ ...EMPTY_BANK_ACCOUNT }],
      preferredTransportIds: [],
    });
    setErrors({ contacts: [{}] });
    setSelectedTransports([]);
  };

  return (
    <>
      {open && (
        <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-start md:items-center justify-center">
          <div className="bg-white dark:bg-gray-900 w-full h-[100dvh] md:h-auto md:max-w-5xl md:max-h-[90vh] md:rounded-lg shadow-lg flex flex-col">
            <div className="p-4 md:p-6 border-b border-gray-200 dark:border-zinc-700">
              <div className="flex items-center gap-3">
                <IconButton onClick={handleClose} aria-label="Go back">
                  <ArrowBackIcon />
                </IconButton>
                <div>
                  <h2 className="text-lg md:text-xl font-semibold">
                    Create Customer
                  </h2>
                  <p className="text-sm text-gray-500 dark:text-gray-400 mt-0.5">
                    Enter customer details to add a new customer
                  </p>
                </div>
              </div>
            </div>

            <div className={`flex-1 overflow-y-auto px-4 md:px-6 py-4 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}>
              <FormSection title="Basic Information" icon={Building2} variantIndex={0}>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <CustomTextField
                    name="customerName"
                    value={form.customerName}
                    onChange={handleFormChange}
                    label="Customer Name *"
                    error={!!errors.customerName}
                    helperText={errors.customerName}
                  />

                  <CustomTextField
                    name="email"
                    value={form.email}
                    onChange={handleFormChange}
                    label="Email"
                    error={!!errors.email}
                    helperText={errors.email}
                  />

                  <CustomTextField
                    name="customerGroup"
                    value={form.customerGroup}
                    onChange={handleFormChange}
                    label="Group Name"
                  />
                  <CustomTextField
                    name="customerGstNo"
                    value={form.customerGstNo}
                    onChange={handleFormChange}
                    label="GST Number"
                  />
                  <BasicSelect
                    name="customerMsme"
                    value={form.customerMsme}
                    onChange={handleFormChange}
                    label="MSME"
                    options={[
                      { value: "Micro", label: "Micro" },
                      { value: "Small", label: "Small" },
                      { value: "Medium", label: "Medium" },
                    ]}
                  />
                  <CustomTextField
                    name="referencedBy"
                    value={form.referencedBy}
                    onChange={handleFormChange}
                    label="Referenced By"
                  />
                </div>
              </FormSection>

              <FormSection title="Address Details" icon={MapPin} variantIndex={1}>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <CustomTextField
                    name="addressLine1"
                    value={form.addressLine1}
                    onChange={handleFormChange}
                    label="Address Line 1"
                  />
                  <CustomTextField
                    name="addressLine2"
                    value={form.addressLine2}
                    onChange={handleFormChange}
                    label="Address Line 2 (Optional)"
                  />
                  <StateAutocomplete
                    value={form.state}
                    onChange={(val) =>
                      setForm((prev) => ({ ...prev, state: val }))
                    }
                  />
                  <CustomTextField
                    name="city"
                    value={form.city}
                    onChange={handleFormChange}
                    label="City"
                  />

                  <CustomTextField
                    name="pinCode"
                    value={form.pinCode}
                    onChange={handleFormChange}
                    label="Pin Code"
                    error={!!errors.pinCode}
                    helperText={errors.pinCode}
                    inputProps={{
                      maxLength: 6,
                      inputMode: "numeric",
                      pattern: "[0-9]*",
                    }}
                  />
                </div>
              </FormSection>

              <FormSection title="Contact Information" icon={Phone} variantIndex={2}>
                {form.contacts.map((contact, index) => (
                  <div key={index} className="mb-6">
                    <div className="md:hidden border rounded-xl p-4 space-y-4 bg-gray-50 dark:bg-zinc-800/50">
                      <div className="flex justify-between items-center">
                        <h4 className="text-sm font-semibold text-gray-700 dark:text-gray-300">
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
                        value={contact.contactPerson}
                        onChange={(e) => handleContactChange(index, e)}
                        label="Contact Person"
                      />

                      <CustomTextField
                        name="mobileNumber"
                        value={contact.mobileNumber}
                        onChange={(e) => {
                          const value = e.target.value;
                          if (/^[0-9-\s]*$/.test(value)) {
                            handleContactChange(index, e);
                          }
                        }}
                        label="Mobile No."
                        type="tel"
                      />

                      <CustomTextField
                        name="type"
                        value={contact.type}
                        onChange={(e) => {
                          if (/^[a-zA-Z _@#&()\-]*$/.test(e.target.value)) {
                            handleContactChange(index, e);
                          }
                        }}
                        label="Type"
                      />
                    </div>

                    <div className="hidden md:grid grid-cols-12 gap-4 items-start">
                      <div className="col-span-4">
                        <CustomTextField
                          name="contactPerson"
                          value={contact.contactPerson}
                          onChange={(e) => handleContactChange(index, e)}
                          label="Contact Person"
                        />
                      </div>

                      <div className="col-span-4">
                        <CustomTextField
                          name="mobileNumber"
                          value={contact.mobileNumber}
                          onChange={(e) => {
                            const value = e.target.value;
                            if (/^[0-9-\s]*$/.test(value)) {
                              handleContactChange(index, e);
                            }
                          }}
                          label="Mobile No."
                          type="tel"
                        />
                      </div>

                      <div className="col-span-3">
                        <CustomTextField
                          name="type"
                          value={contact.type}
                          onChange={(e) => {
                            if (/^[a-zA-Z _@#&()\-]*$/.test(e.target.value)) {
                              handleContactChange(index, e);
                            }
                          }}
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
                  sx={{ mt: 1 }}
                >
                  Add Contact
                </Button>
              </FormSection>

              <FormSection title="Preferred Transports" icon={Truck} variantIndex={3}>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <Autocomplete
                    multiple
                    options={allTransports}
                    value={selectedTransports}
                    loading={transportLoading}
                    filterSelectedOptions
                    isOptionEqualToValue={(o, v) => o.id === v.id}
                    getOptionLabel={(o) => o.name}
                    renderOption={(props, option) => (
                      <li {...props} key={option.id}>
                        {option.name} – {option.city}
                      </li>
                    )}
                    onChange={(e, values) => {
                      setSelectedTransports(values);
                      setForm((prev) => ({
                        ...prev,
                        preferredTransportIds: values.map((v) => v.id),
                      }));
                      setErrors((prev) => ({
                        ...prev,
                        preferredTransportIds: "",
                      }));
                    }}
                    renderTags={(value, getTagProps) =>
                      value.map((option, index) => {
                        const { key, ...tagProps } = getTagProps({ index });

                        return (
                          <Chip
                            key={key}
                            label={option.name}
                            size="small"
                            {...tagProps}
                          />
                        );
                      })
                    }
                    renderInput={(params) => (
                      <CustomTextField
                        {...params}
                        label="Preferred Transports"
                        placeholder="Type transport name"
                      />
                    )}
                  />

                  <CustomTextField
                    name="remark"
                    value={form.remark}
                    onChange={handleFormChange}
                    label="Remarks (optional)"
                    size="small"
                    multiline
                  />
                </div>
              </FormSection>

              <FormSection title="Bank Details" icon={Landmark} variantIndex={4}>
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
                        value={account.bankName}
                        onChange={(e) => handleBankAccountChange(index, e)}
                        label="Bank Name"
                      />

                      <CustomTextField
                        name="ifscCode"
                        value={account.ifscCode}
                        onChange={(e) => handleBankAccountChange(index, e)}
                        label="IFSC Code"
                      />

                      <CustomTextField
                        name="branchName"
                        value={account.branchName}
                        onChange={(e) => handleBankAccountChange(index, e)}
                        label="Branch Name"
                      />

                      <CustomTextField
                        name="accountName"
                        value={account.accountName}
                        onChange={(e) => handleBankAccountChange(index, e)}
                        label="Account Holder Name"
                      />

                      <CustomTextField
                        name="accountNumber"
                        value={account.accountNumber}
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
              </FormSection>
            </div>

            <FormFooter>
              <AppButton
                type="cancel"
                disabled={isSaving}
                onClick={handleClose}
              >
                Cancel
              </AppButton>

              <AppButton
                type="secondary"
                loading={isSaving}
                onClick={() => handleAddCustomer({ closeAfterSave: false })}
              >
                Save & Add New
              </AppButton>

              <AppButton
                type="primary"
                loading={isSaving}
                onClick={() => handleAddCustomer({ closeAfterSave: true })}
              >
                Save Customer
              </AppButton>
            </FormFooter>

            <ConfirmDialog
              open={confirmOpen}
              onConfirm={handleConfirmLeave}
              onCancel={handleStay}
            />
          </div>
        </div>
      )}
    </>
  );
};

export default AddNewCustomer;
