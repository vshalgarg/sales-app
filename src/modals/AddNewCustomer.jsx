import { Button, IconButton, Autocomplete, TextField, Chip } from "@mui/material";
import { useState, useEffect } from "react";
import BasicSelect from "../components/BasicSelect";
import CustomTextField from "../components/CustomTextField";
import AddIcon from "@mui/icons-material/Add";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import CustomerService from "../service/CustomerService";
import { useSnackbar } from "../context/SnackbarContext";
import validate from "../validations/Validation";
import TransportService from "../service/TransportService";
import { sanitizePayload } from "../utils/sanitizePayload";
import StateAutocomplete from "../components/common/StateAutocomplete";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import FormFooter from "../components/common/FormFooter";
import AppButton from "../components/common/AppButton";
import useUnsavedChanges from "../customHooks/useUnsavedChanges";
import ConfirmDialog from "../components/common/ConfirmDialog";

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


  /* ---------- Load all transports once ---------- */
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
  }, []);

  const handleFormChange = (e) => {
    const { name, value } = e.target;

    // PinCode: digits only, max 6
    if (name === "pinCode") {
      if (!/^\d{0,6}$/.test(value)) return;

      setForm(prev => ({ ...prev, pinCode: value }));
      setErrors(prev => ({ ...prev, pinCode: validate("pinCode", value) }));
      return;
    }

    // fields (state, city, others)
    setForm(prev => ({
      ...prev,
      [name]: value,
    }));
    setErrors(prev => ({ ...prev, [name]: validate(name, value) }));
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

    // Update form
    const newContacts = [...form.contacts];
    newContacts[index][name] = value;
    setForm({ ...form, contacts: newContacts });

    // Validate field
    const errorMsg = validate(name, value);
    const updatedContactErrors = [...errors.contacts];
    if (!updatedContactErrors[index]) updatedContactErrors[index] = {};
    updatedContactErrors[index][name] = errorMsg;

    setErrors((prev) => ({
      ...prev,
      contacts: updatedContactErrors,
    }));
  };

  const handleAddCustomer = async ({ closeAfterSave }) => {
    if (isSaving) return;

    const nameError = validate("customerName", form.customerName);

    if (nameError) {
      setErrors(prev => ({
        ...prev,
        customerName: nameError,
      }));

      showSnackbar(nameError, "error");
      return;
    }

    const payload = sanitizePayload({
      ...form,
      preferredTransportIds: selectedTransports.map((t) => t.id),
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
        ])
      ),
      contacts: [{ contactPerson: "", mobileNumber: "", type: "" }],
      preferredTransportIds: [],
    });
    setErrors({ contacts: [{}] });
    setSelectedTransports([]);
  };

  return (
    <>
      {open && (
        <div className="fixed inset-0 bg-black bg-opacity-80 z-50 
                flex items-start md:items-center justify-center">
          <div className="bg-white w-full 
                h-[100dvh] md:h-auto
                md:max-w-4xl md:max-h-[90vh] 
                md:rounded-lg shadow-lg 
                flex flex-col">
            {/* Header */}
            <div className="p-4 md:p-6 border-b flex items-center gap-3">
              <IconButton
                onClick={handleClose}
                className="md:hidden"
              >
                <ArrowBackIcon />
              </IconButton>

              <h2 className="text-lg md:text-xl font-semibold">
                Add New Customer
              </h2>
            </div>

            {/* Scrollable form content */}
            <div className="flex-1 overflow-y-auto px-6 py-4 space-y-6">
              {/* Basic Information */}
              <div>
                <h3 className="text-lg font-medium mb-2">Basic Information</h3>
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
              </div>

              {/* Bank Details */}
              <div>
                <h3 className="text-lg font-medium mb-2">Bank Details</h3>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

                  <CustomTextField
                    name="bankName"
                    value={form.bankName}
                    onChange={handleFormChange}
                    label="Bank Name"
                  />

                  <CustomTextField
                    name="branch"
                    value={form.branch}
                    onChange={handleFormChange}
                    label="Branch"
                  />

                  <CustomTextField
                    name="ifsc"
                    value={form.ifsc}
                    onChange={handleFormChange}
                    label="IFSC Code"
                  />

                  <CustomTextField
                    name="accountName"
                    value={form.accountName}
                    onChange={handleFormChange}
                    label="Account Holder Name"
                  />

                  <CustomTextField
                    name="accountNumber"
                    value={form.accountNumber}
                    onChange={handleFormChange}
                    label="Account Number"
                  />

                </div>
              </div>

              {/* Address Details */}
              <div>
                <h3 className="text-lg font-medium mb-2">Address Details</h3>
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
                    label="Address Line 2"
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
              </div>

              {/* Contact Information */}
              <div>
                <h3 className="text-lg font-medium mb-2">Contact Information</h3>
                {form.contacts.map((contact, index) => (
                  <div key={index} className="mb-6">

                    {/* Mobile Contact Card */}
                    <div className="md:hidden border rounded-xl p-4 space-y-4 bg-gray-50">

                      {/* Heading */}
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

                    {/* Desktop Layout */}
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
              </div>

              {/* Financial & Logistics - Transport & Remark*/}
              <div>
                <h3 className="text-lg font-medium mb-3">Financial & Logistics</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Transport Autocomplete */}
                  <div>
                    <label className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      Preferred Transports
                    </label>
                    <Autocomplete
                      multiple
                      options={allTransports}
                      value={selectedTransports}
                      loading={transportLoading}
                      filterSelectedOptions
                      isOptionEqualToValue={(o, v) => o.id === v.id}

                      // search NAME
                      getOptionLabel={(o) => o.name}

                      // dropdown NAME + CITY
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
                        setErrors((prev) => ({ ...prev, preferredTransportIds: "" }));
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
                  </div>

                  {/* Remark */}
                  <div>
                    <label className=" text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      Remarks
                    </label>
                    <CustomTextField
                      name="remark"
                      value={form.remark}
                      onChange={handleFormChange}
                      label="Remarks (optional)"
                      size="small"
                      multiline
                    />
                  </div>
                </div>
              </div>
            </div>

            <FormFooter className="border-t p-4">
              {/* Save Customer */}
              <AppButton
                type="primary"
                loading={isSaving}
                onClick={() => handleAddCustomer({ closeAfterSave: true })}
              >
                Save Customer
              </AppButton>

              {/* Save & Add New */}
              <AppButton
                type="secondary"
                loading={isSaving}
                onClick={() => handleAddCustomer({ closeAfterSave: false })}
              >
                Save & Add New
              </AppButton>

              {/* Cancel */}
              <AppButton
                type="cancel"
                disabled={isSaving}
                onClick={handleClose}
              >
                Cancel
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