import {
  Button,
  IconButton,
  CircularProgress,
} from "@mui/material";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import AddIcon from "@mui/icons-material/Add";
import Autocomplete from "@mui/material/Autocomplete";
import Chip from "@mui/material/Chip";
import { useEffect, useState } from "react";
import CustomTextField from "../components/CustomTextField";
import BasicSelect from "../components/BasicSelect";
import CustomerService from "../service/CustomerService";
import TransportService from "../service/TransportService";
import { useSnackbar } from "../context/SnackbarContext";
import validate from "../validations/Validation";
import { sanitizePayload } from "../utils/sanitizePayload";

const UpdateCustomerModal = ({
  customerId,
  open,
  setOpen,
  fetchCustomers,
}) => {

  const { showSnackbar } = useSnackbar();

  const [form, setForm] = useState({});
  const [errors, setErrors] = useState({ contacts: [{}] });
  const [allTransports, setAllTransports] = useState([]);
  const [selectedTransports, setSelectedTransports] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  /* ================= FETCH CUSTOMER ================= */

  useEffect(() => {
    if (!customerId || !open) return;

    const fetchCustomer = async () => {
      try {
        setLoading(true);

        const response = await CustomerService.getCustomerById(customerId);
        const data = response.data || response;

        setForm({
          customerName: data.customerName || "",
          email: data.email || "",
          groupName: data.groupName || "",
          gstNo: data.gstNo || "",
          referencedBy: data.referencedBy || "",
          addressLine1: data.addressLine1 || "",
          addressLine2: data.addressLine2 || "",
          state: data.state || "",
          city: data.city || "",
          pinCode: data.pinCode || "",
          msme: data.msme || "",
          remark: data.remark || "",
          contacts: data.contacts?.length
            ? data.contacts
            : [{ contactPerson: "", mobileNumber: "", type: "" }],
        });

        setSelectedTransports(data.preferredTransports || []);

      } catch (err) {
        showSnackbar("Failed to load customer", "error");
      } finally {
        setLoading(false);
      }
    };

    fetchCustomer();
  }, [customerId, open]);

  /* ================= FETCH TRANSPORTS ================= */

  useEffect(() => {
    const fetchTransports = async () => {
      const transports = await TransportService.getAllTransports();
      setAllTransports(transports || []);
    };
    fetchTransports();
  }, []);

  /* ================= HANDLERS ================= */

  const handleChange = (e) => {
    const { name, value } = e.target;

    setForm(prev => ({ ...prev, [name]: value }));
    setErrors(prev => ({ ...prev, [name]: validate(name, value) }));
  };

  const handleContactChange = (index, e) => {
    const { name, value } = e.target;
    const updated = [...form.contacts];
    updated[index][name] = value;
    setForm(prev => ({ ...prev, contacts: updated }));
  };

  const addContact = () => {
    setForm(prev => ({
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
    setForm(prev => ({ ...prev, contacts: updated }));
  };

  /* ================= UPDATE ================= */

  const handleUpdate = async () => {

    const nameError = validate("customerName", form.customerName);
    if (nameError) {
      showSnackbar(nameError, "error");
      return;
    }

    const payload = sanitizePayload({
      ...form,
      preferredTransportIds: selectedTransports.map(t => t.id),
    });

    try {
      setIsSaving(true);
      await CustomerService.updateCustomer(customerId, payload);
      showSnackbar("Customer updated successfully!", "success");
      fetchCustomers();
      setOpen(false);
    } catch (err) {
      showSnackbar(err.message || "Update failed", "error");
    } finally {
      setIsSaving(false);
    }
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center">

      <div className="bg-white w-full h-full md:max-w-4xl md:max-h-[90vh] md:rounded-lg flex flex-col">

        {/* HEADER */}
        <div className="p-6 border-b">
          <h2 className="text-xl font-semibold">Update Customer</h2>
        </div>

        {/* BODY */}
        {loading ? (
          <div className="flex-1 flex items-center justify-center">
            <CircularProgress />
          </div>
        ) : (

          <div className="px-6 py-4 overflow-y-auto flex-1 space-y-8">

            {/* ================= BASIC INFORMATION ================= */}
            <div>
              <h3 className="text-lg font-semibold mb-4 border-b pb-2">
                Basic Information
              </h3>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

                <CustomTextField
                  name="customerName"
                  value={form.customerName || ""}
                  onChange={handleChange}
                  label="Customer Name *"
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
                    { value: "Micro", label: "Micro" },
                    { value: "Small", label: "Small" },
                    { value: "Medium", label: "Medium" },
                  ]}
                />

                <CustomTextField
                  name="referencedBy"
                  value={form.referencedBy || ""}
                  onChange={handleChange}
                  label="Referenced By"
                />

              </div>
            </div>

            {/* ================= ADDRESS DETAILS ================= */}
            <div>
              <h3 className="text-lg font-semibold mb-4 border-b pb-2">
                Address Details
              </h3>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

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
                  label="Address Line 2"
                />

                <CustomTextField
                  name="state"
                  value={form.state || ""}
                  onChange={handleChange}
                  label="State"
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

              </div>
            </div>

            {/* ================= CONTACT INFORMATION ================= */}
            <div>
              <h3 className="text-lg font-semibold mb-4 border-b pb-2">
                Contact Information
              </h3>

              {form.contacts?.map((contact, index) => (
                <div
                  key={index}
                  className="grid grid-cols-1 md:grid-cols-12 gap-4 mb-4 items-start"
                >

                  <div className="md:col-span-4">
                    <CustomTextField
                      name="contactPerson"
                      value={contact.contactPerson || ""}
                      onChange={(e) => handleContactChange(index, e)}
                      label="Contact Person"
                    />
                  </div>

                  <div className="md:col-span-4">
                    <CustomTextField
                      name="mobileNumber"
                      value={contact.mobileNumber || ""}
                      onChange={(e) => handleContactChange(index, e)}
                      label="Mobile Number"
                    />
                  </div>

                  <div className="md:col-span-3">
                    <CustomTextField
                      name="type"
                      value={contact.type || ""}
                      onChange={(e) => handleContactChange(index, e)}
                      label="Type"
                    />
                  </div>

                  {index > 0 && (
                    <div className="md:col-span-1 flex justify-center">
                      <IconButton
                        size="small"
                        color="error"
                        onClick={() => deleteContact(index)}
                      >
                        <DeleteOutlineIcon fontSize="small" />
                      </IconButton>
                    </div>
                  )}

                </div>
              ))}

              <Button
                variant="outlined"
                startIcon={<AddIcon />}
                onClick={addContact}
              >
                Add Contact
              </Button>
            </div>

            {/* ================= TRANSPORT & REMARK ================= */}
            <div>
              <h3 className="text-lg font-semibold mb-4 border-b pb-2">
                Transport & Remarks
              </h3>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

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
                    <CustomTextField
                      {...params}
                      label="Preferred Transports"
                    />
                  )}
                />

                <CustomTextField
                  name="remark"
                  value={form.remark || ""}
                  onChange={handleChange}
                  label="Remarks"
                  multiline
                  rows={0}
                />

              </div>
            </div>

          </div>
        )}

        {/* FOOTER */}
        <div className="p-4 border-t flex flex-col sm:flex-row justify-end gap-3 bg-gray-50">

          <Button onClick={() => setOpen(false)}>
            Cancel
          </Button>

          <Button
            variant="contained"
            onClick={handleUpdate}
            disabled={isSaving}
          >
            {isSaving ? "Updating..." : "Update Customer"}
          </Button>

        </div>

      </div>
    </div>
  );
};

export default UpdateCustomerModal;
