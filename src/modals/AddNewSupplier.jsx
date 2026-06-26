import { Button, IconButton } from "@mui/material";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import BasicSelect from "../components/BasicSelect";
import { useSnackbar } from "../context/SnackbarContext";
import validate from "../validations/Validation";
import CustomTextField from "../components/CustomTextField";
import { useEffect, useState } from "react";
import AddIcon from "@mui/icons-material/Add";
import SupplierService from "../service/SupplierService";
import TransportService from "../service/TransportService";
import Autocomplete from "@mui/material/Autocomplete";
import { sanitizePayload } from "../utils/sanitizePayload";
import Chip from "@mui/material/Chip";
import StateAutocomplete from "../components/common/StateAutocomplete";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import AppButton from "../components/common/AppButton";
import FormFooter from "../components/common/FormFooter";
import FormSection from "../components/common/FormSection";
import { FORM_SCROLL_AREA_CLASS } from "../theme/cardTheme";
import ConfirmDialog from "../components/common/ConfirmDialog";
import useUnsavedChanges from "../customHooks/useUnsavedChanges";
import {
  Building2,
  MapPin,
  Phone,
  Truck,
  Landmark,
} from "lucide-react";

const AddNewSupplier = ({ form, open, setOpen, setForm, fetchSuppliers }) => {
  const [errors, setErrors] = useState({
    contacts: [{}],
  });
  const { showSnackbar } = useSnackbar();
  const [selectedTransports, setSelectedTransports] = useState([]);
  const [allTransports, setAllTransports] = useState([]);
  const [transportLoading, setTransportLoading] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const { isDirty } = useUnsavedChanges(form, open);
  const [confirmOpen, setConfirmOpen] = useState(false);


  useEffect(() => {
    const fetchTransports = async () => {
      try {
        setTransportLoading(true);
        const transports = await TransportService.getAllTransports();
        setAllTransports(transports || []);
      } catch (err) {
        console.error(err);
      } finally {
        setTransportLoading(false);
      }
    };
    fetchTransports();
  }, []);


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

  // Add new empty contact
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

  const handleFormChange = (e) => {
    const { name, value } = e.target;

    if (name === "pinCode" && !/^\d{0,6}$/.test(value)) return;

    // 🔹commissionRate (max 100, 2 decimals)
    if (name === "commissionRate") {
      if (
        /^\d*\.?\d{0,2}$/.test(value) &&
        (value === "" || parseFloat(value) <= 100)
      ) {
        setForm(prev => ({ ...prev, commissionRate: value }));

        setErrors(prev => ({
          ...prev,
          commissionRate: validate("commissionRate", value),
        }));
      }
      return;
    }

    // 🔹fields (state, city, pinCode, others)
    setForm(prev => ({
      ...prev,
      [name]: value,
    }));

    // 🔹 Validation
    setErrors(prev => ({ ...prev, [name]: validate(name, value) }));
  };


  const handleAddSupplier = async ({ closeAfterSave }) => {
    if (isSaving) return;

    const nameError = validate("supplierName", form.supplierName);

    if (nameError) {
      setErrors({ supplierName: nameError });
      showSnackbar(nameError, "error");
      return;
    }

    const payload = sanitizePayload({
      ...form,
      preferredTransportIds: selectedTransports.map((t) => t.id),
    });

    try {
      setIsSaving(true);

      const response = await SupplierService.saveSupplier(payload);

      if (response?.code && response?.message) {
        showSnackbar(response.message, "error");
        return;
      }

      showSnackbar("Supplier added successfully!", "success");
      fetchSuppliers();
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
        <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-start md:items-center justify-center">
          <div className="bg-white dark:bg-gray-900 w-full h-[100dvh] md:h-auto md:max-w-5xl md:max-h-[90vh] md:rounded-lg shadow-lg flex flex-col">
            {/* Header */}
            <div className="p-4 md:p-6 border-b border-gray-200 dark:border-zinc-700">
              <div className="flex items-center gap-3">
                <IconButton onClick={handleClose} aria-label="Go back">
                  <ArrowBackIcon />
                </IconButton>
                <div>
                  <h2 className="text-lg md:text-xl font-semibold">
                    Create Supplier
                  </h2>
                  <p className="text-sm text-gray-500 dark:text-gray-400 mt-0.5">
                    Enter supplier details to add a new supplier
                  </p>
                </div>
              </div>
            </div>

            {/* Scrollable form content */}
            <div className={`flex-1 overflow-y-auto px-4 md:px-6 py-4 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}>
              <FormSection title="Basic Information" icon={Building2} variantIndex={0}>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <CustomTextField
                    name="supplierName"
                    value={form.supplierName}
                    onChange={handleFormChange}
                    label="Supplier Name *"
                    className="border p-2 rounded"
                    error={!!errors.supplierName}
                    helperText={errors.supplierName}
                  />

                  <CustomTextField
                    name="email"
                    value={form.email}
                    onChange={handleFormChange}
                    label="Email"
                    className="border p-2 rounded"
                    error={!!errors.email}
                    helperText={errors.email}
                    type="email"
                  />

                  <CustomTextField
                    name="supplierGroup"
                    value={form.supplierGroup}
                    onChange={handleFormChange}
                    label="Group"
                    className="border p-2 rounded"
                  />
                  <CustomTextField
                    name="supplierGstNo"
                    value={form.supplierGstNo}
                    onChange={handleFormChange}
                    label="GST Number"
                    className="border p-2 rounded"

                  />
                  <BasicSelect
                    name="supplierMsme"
                    value={form.supplierMsme}
                    onChange={handleFormChange}
                    label="MSME"
                    options={[
                      { value: "Micro", label: "Micro" },
                      { value: "Small", label: "Small" },
                      { value: "Medium", label: "Medium" },
                    ]}
                  />
                  <BasicSelect
                    name="commissionScheme"
                    value={form.commissionScheme}
                    onChange={handleFormChange}
                    label="Commission Scheme"
                    options={[
                      { value: "Fixed", label: "Fixed" },
                      { value: "Percentage", label: "Percentage" },
                      { value: "Tiered", label: "Tiered" },
                    ]}
                  />
                  <CustomTextField
                    name="commissionRate"
                    value={form.commissionRate}
                    onChange={handleFormChange}
                    label="Commission % (Rate)"
                    className="border p-2 rounded"
                  />

                  <CustomTextField
                    name="referenceBy"
                    value={form.referenceBy}
                    onChange={handleFormChange}
                    label="Reference By"
                    className="border p-2 rounded"
                    error={!!errors.referenceBy}
                    helperText={errors.referenceBy}
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
                    className="border p-2 rounded"
                  />
                  <CustomTextField
                    name="addressLine2"
                    value={form.addressLine2}
                    onChange={handleFormChange}
                    label="Address Line 2 (Optional)"
                    className="border p-2 rounded"
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
                    className="border p-2 rounded"
                  />

                  <CustomTextField
                    name="pinCode"
                    value={form.pinCode}
                    onChange={handleFormChange}
                    label="Pin Code"
                    error={!!errors.pinCode}
                    helperText={errors.pinCode}
                  />
                </div>
              </FormSection>

              <FormSection title="Contact Information" icon={Phone} variantIndex={2}>
                {form.contacts.map((contact, index) => (
                  <div key={index} className="mb-6">

                    {/* Mobile Contact Card */}
                    <div className="md:hidden border rounded-xl p-4 space-y-4 bg-gray-50">

                      {/* Heading*/}
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
                        className="w-full"
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
                        onChange={(e) => handleContactChange(index, e)}
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
                        error={!!errors.preferredTransportIds}
                        helperText={errors.preferredTransportIds}
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
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <CustomTextField
                    name="bankName"
                    value={form.bankName}
                    onChange={handleFormChange}
                    label="Bank Name"
                    type="text"
                  />

                  <CustomTextField
                    name="ifscCode"
                    value={form.ifscCode}
                    onChange={handleFormChange}
                    label="IFSC Code"
                  />

                  <CustomTextField
                    name="branchName"
                    value={form.branchName}
                    onChange={handleFormChange}
                    label="Branch Name"
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
                    type="number"
                  />
                </div>
              </FormSection>
            </div>

            {/* Footer*/}
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
                onClick={() => handleAddSupplier({ closeAfterSave: false })}
              >
                Save & Add New
              </AppButton>

              <AppButton
                type="primary"
                loading={isSaving}
                onClick={() => handleAddSupplier({ closeAfterSave: true })}
              >
                Save Supplier
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

export default AddNewSupplier;
