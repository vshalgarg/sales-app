import { Button, IconButton, Autocomplete, TextField } from "@mui/material";
import { useState, useEffect } from "react";
import BasicSelect from "../components/BasicSelect";
import CustomTextField from "../components/CustomTextField";
import AddIcon from "@mui/icons-material/Add";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import { saveCustomer } from "../service/CustomerService";
import { useSnackbar } from "../context/SnackbarContext";
import validate from "../validations/Validation";

const AddNewCustomer = ({ form, open, setOpen, setForm, fetchCustomers }) => {
  const [errors, setErrors] = useState({
    contacts: [{}],
  });
  const [touched, setTouched] = useState({});

  const [states, setStates] = useState([]);
  const [pinCodes, setPinCodes] = useState([]);
  const [cities, setCities] = useState([]);
  const { showSnackbar } = useSnackbar();

  const handleFormChange = (e) => {
    const { name, value } = e.target;

    // 🧠 New: handle dependency clearing
    if (name === "state") {
      setForm((prev) => ({
        ...prev,
        state: value,
        city: "", // clear city when state removed or changed
        pinCode: "", // clear pin when state removed or changed
      }));
    } else if (name === "city") {
      setForm((prev) => ({
        ...prev,
        city: value,
        pinCode: "", // clear pin when city removed or changed
      }));
    } else {
      setForm({ ...form, [name]: value });
    }

    // mark field as touched for validation
    setTouched((prev) => ({ ...prev, [name]: true }));

    // validate current field
    setErrors((prev) => ({ ...prev, [name]: validate(name, value) }));
  };

  const addContact = () => {
    setForm({
      ...form,
      contacts: [
        ...form.contacts,
        { contactPerson: "", mobileNumber: "", phone: "" },
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

  const handleMultiSelectChange = (e) => {
    const { name, value, error } = e.target; // value is guaranteed array by BasicSelect
    setForm((prev) => ({
      ...prev,
      [name]: value,
    }));

    const errMsg = error || validate(name, value); // <- use custom error first
    setErrors((prev) => ({
      ...prev,
      [name]: errMsg,
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

  useEffect(() => {
    fetch(
      "http://api.geonames.org/searchJSON?country=IN&featureClass=P&maxRows=1000&username=tarunbaisla_14"
    )
      .then((res) => res.json())
      .then((data) => {
        const uniqueStates = [
          ...new Set(data.geonames.map((c) => c.adminName1)),
        ];
        setStates(uniqueStates.sort().map((s) => ({ name: s })));
      })
      .catch((err) => console.error("Error fetching states:", err));
  }, []);

  useEffect(() => {
    if (!form.state) return;

    fetch(
      "http://api.geonames.org/searchJSON?country=IN&featureClass=P&maxRows=1000&username=tarunbaisla_14"
    )
      .then((res) => res.json())
      .then((data) => {
        const filteredCities = data.geonames
          .filter((c) => c.adminName1 === form.state)
          .map((c) => c.name);
        setCities([...new Set(filteredCities)].sort());
      })
      .catch((err) => console.error("Error fetching cities:", err));
  }, [form.state]);

  // Inside your component
  useEffect(() => {
    if (!form.city) return;

    fetch(
      `http://api.geonames.org/postalCodeSearchJSON?placename=${form.city}&country=IN&maxRows=10&username=tarunbaisla_14`
    )
      .then((res) => res.json())
      .then((data) => {
        if (data.postalCodes && data.postalCodes.length > 0) {
          // Take the first pin only (autofill, not dropdown)
          const pin = data.postalCodes[0].postalCode;
          setForm((prev) => ({ ...prev, pinCode: pin }));
        } else {
          // If no pin found, keep empty so user can type manually
          setForm((prev) => ({ ...prev, pinCode: "" }));
        }
      })
      .catch((err) => console.error("Error fetching pincode:", err));
  }, [form.city]);
  // ✅ runs whenever city changes

  const handleAddCustomer = async () => {
    const newErrors = {};
    let contactErrors = [];

    // Validate top-level fields
    Object.keys(form).forEach((field) => {
      if (field !== "contacts") {
        const error = validate(field, form[field]);
        if (error) newErrors[field] = error;
      }
    });

    // Validate each contact field
    contactErrors = form.contacts.map((contact) => {
      const contactError = {};
      ["contactPerson", "mobileNumber", "phone"].forEach((field) => {
        const error = validate(field, contact[field]);
        if (error) contactError[field] = error;
      });
      return contactError;
    });

    newErrors.contacts = contactErrors;
    setErrors(newErrors);

    // Check if any errors exist
    const hasTopLevelErrors = Object.keys(newErrors).some(
      (key) => key !== "contacts" && newErrors[key]
    );
    const hasContactErrors = contactErrors.some((err) =>
      Object.values(err).some((msg) => !!msg)
    );

    if (hasTopLevelErrors || hasContactErrors) {
      showSnackbar("Please fill required fields in the form.", "error");
      return; // Don’t proceed
    }

    // Save customer
    try {
      const response = await saveCustomer(form);
      if (
        response &&
        typeof response === "object" &&
        "code" in response &&
        "message" in response &&
        "timestamp" in response
      ) {
        showSnackbar(response.message, "error");
        return;
      }
      showSnackbar(response.message, "success");
      console.log("Customer added successfully : ", response);
      resetForm();
      setOpen(false);
      fetchCustomers();
    } catch (err) {
      console.error("🔥 Error while saving supplier:", err);
      showSnackbar("Network or server error.", "error");
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
      contacts: [{ contactPerson: "", mobileNumber: "", phone: "" }],
    });
    setErrors({ contacts: [{}] });
  };

  return (
    <>
      {open && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-80 z-50">
          <div className="bg-white w-full max-w-4xl max-h-[90vh] rounded-lg shadow-lg flex flex-col">
            {/* Header */}
            <div className="p-6 border-b">
              <h2 className="text-xl font-semibold">Add New Customer</h2>
            </div>

            {/* Scrollable form content */}
            <div className="px-6 py-4 overflow-y-auto flex-1 space-y-6">
              {/* Basic Information */}
              <div>
                <h3 className="text-lg font-medium mb-2">Basic Information</h3>
                <div className="grid grid-cols-2 gap-4">
                  <CustomTextField
                    name="customerName"
                    value={form.customerName}
                    onChange={handleFormChange}
                    label="Customer Name"
                    className="border p-2 rounded"
                    error={!!errors.customerName}
                    helperText={errors.customerName}
                  />

                  <CustomTextField
                    name="customerGroup"
                    value={form.customerGroup}
                    onChange={handleFormChange}
                    label="Group Name"
                    className="border p-2 rounded"
                    error={!!errors.customerGroup}
                    helperText={errors.customerGroup || ""}
                  />

                  <CustomTextField
                    name="customerGstNo"
                    value={form.customerGstNo}
                    onChange={handleFormChange}
                    label="GST Number"
                    className="border p-2 rounded"
                    error={!!errors.customerGstNo}
                    helperText={errors.customerGstNo || ""}
                  />

                  <BasicSelect
                    name="customerMsme"
                    value={form.customerMsme}
                    onChange={handleFormChange}
                    label="MSME"
                    className="border p-2 rounded"
                    error={!!errors.customerMsme}
                    helperText={errors.customerMsme || ""}
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
                    className="border p-2 rounded"
                    error={!!errors.referencedBy}
                    helperText={errors.referencedBy || ""}
                  />
                </div>
              </div>

              {/* Address Details */}
              <div>
                <h3 className="text-lg font-medium mb-2">Address Details</h3>
                <div className="grid grid-cols-2 gap-4">
                  <CustomTextField
                    name="addressLine1"
                    value={form.addressLine1}
                    onChange={handleFormChange}
                    label="Address Line 1"
                    className="border p-2 rounded"
                    error={!!errors.addressLine1}
                    helperText={errors.addressLine1}
                  />
                  <CustomTextField
                    name="addressLine2"
                    value={form.addressLine2}
                    onChange={handleFormChange}
                    label="Address Line 2 (Optional)"
                    className="border p-2 rounded"
                  />
                  <BasicSelect
                    name="state"
                    value={form.state}
                    onChange={handleFormChange}
                    label="Select State"
                    error={!!errors.state}
                    helperText={errors.state || ""}
                    options={states.map((s) => ({
                      value: s.name,
                      label: s.name,
                    }))}
                  />

                  <BasicSelect
                    name="city"
                    value={form.city}
                    onChange={handleFormChange}
                    label="Select City"
                    error={!!errors.city}
                    helperText={errors.city || ""}
                    options={cities.map((c) => ({
                      value: c,
                      label: c,
                    }))}
                    disabled={!form.state}
                  />

                  <CustomTextField
                    name="pinCode"
                    value={form.pinCode}
                    readOnly
                    label="Pin Code"
                    disabled={!form.state} // ✅ disabled until state is chosen
                    className="border p-2 rounded cursor-not-allowed"
                  />
                </div>
              </div>

              {/* Contact Information */}
              <div>
                <h3 className="text-lg font-medium mb-2">
                  Contact Information
                </h3>
                {form.contacts.map((contact, index) => (
                  <div
                    key={index}
                    className="grid grid-cols-12 gap-4 mb-4 items-start"
                  >
                    <div className="col-span-4">
                      <CustomTextField
                        name="contactPerson"
                        value={contact.contactPerson}
                        onChange={(e) => handleContactChange(index, e)}
                        label="Contact Person"
                        className="w-full border p-2 rounded"
                        error={!!errors.contacts?.[index]?.contactPerson}
                        helperText={errors.contacts?.[index]?.contactPerson}
                      />
                    </div>
                    <div className="col-span-4">
                      <CustomTextField
                        name="mobileNumber"
                        value={contact.mobileNumber}
                        onChange={(e) => {
                          const value = e.target.value;
                          if (/^\d{0,10}$/.test(value)) {
                            handleContactChange(index, e);
                          }
                        }}
                        label="Mobile No."
                        className="w-full border p-2 rounded"
                        error={!!errors.contacts?.[index]?.mobileNumber}
                        helperText={errors.contacts?.[index]?.mobileNumber}
                        type="tel"
                        inputProps={{ maxLength: 10 }}
                      />
                    </div>
                    <div className="col-span-3">
                      <CustomTextField
                        name="phone"
                        value={contact.phone}
                        onChange={(e) => {
                          const value = e.target.value;
                          if (/^\d{0,10}$/.test(value)) {
                            handleContactChange(index, e);
                          }
                        }}
                        label="Phone No."
                        className="w-full border p-2 rounded"
                        error={!!errors.contacts?.[index]?.phone}
                        helperText={errors.contacts?.[index]?.phone}
                        type="tel"
                        inputProps={{ maxLength: 10 }}
                      />
                    </div>

                    {/* Delete icon button - hidden for first contact */}
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

              {/* Financial & Logistics */}
              <div>
                <h3 className="text-lg font-medium mb-2">
                  Financial & Logistics
                </h3>
                <div className="grid grid-cols-2 gap-4">
                  <CustomTextField
                    name="preferredTransport"
                    value={form.preferredTransport.join(", ")}
                    onChange={(e) => {
                      const { name, value } = e.target;

                      // 🧠 Update the form
                      const newValue = value
                        ? value.split(",").map((v) => v.trim())
                        : [];

                      setForm((prev) => ({
                        ...prev,
                        [name]: newValue,
                      }));

                      // ✅ Validate immediately
                      const errMsg = validate(name, newValue);
                      setErrors((prev) => ({
                        ...prev,
                        [name]: errMsg,
                      }));

                      // ✅ Mark field as touched (optional)
                      setTouched((prev) => ({
                        ...prev,
                        [name]: true,
                      }));
                    }}
                    label="Preferred Transport"
                    error={!!errors.preferredTransport}
                    helperText={errors.preferredTransport || ""}
                  />

                  <CustomTextField
                    name="remark"
                    value={form.remark}
                    onChange={handleFormChange}
                    label="Remarks"
                    className="border p-2 rounded"
                  />
                </div>
              </div>
            </div>

            {/* Footer with buttons */}
            <div className="p-4 border-t flex justify-end space-x-3">
              <button
                onClick={() => {
                  resetForm();
                  setOpen(false);
                }}
                className="px-4 py-2 border rounded-lg hover:bg-gray-200"
              >
                Cancel
              </button>
              <button
                type="submit"
                onClick={handleAddCustomer}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              >
                Save Customer
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default AddNewCustomer;
