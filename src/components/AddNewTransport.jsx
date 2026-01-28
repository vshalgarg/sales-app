import { useState, useEffect } from "react";
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  Stack,
  Typography,
  RadioGroup,
  FormControlLabel,
  Radio,
  CircularProgress,
  Divider,
  IconButton,
  Box,
} from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import TransportService from "../service/TransportService";
import { useSnackbar } from "../context/SnackbarContext";

export default function AddNewTransport({
  open,
  setOpen,
  editingTransport = null,
  onSuccess,
}) {
  const { showSnackbar } = useSnackbar();

  /* ================= STATE ================= */
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    gstNo: "",
    contacts: [{ contactPerson: "", contactNumber: "" }],
    state: "",
    city: "",
    addressLine1: "",
    addressLine2: "",
    status: "ACTIVE",
  });

  const [errors, setErrors] = useState({});
  const [isSaving, setIsSaving] = useState(false);

  /* ================= RESET ================= */
  const resetForm = () => {
    setFormData({
      name: "",
      email: "",
      gstNo: "",
      contacts: [{ contactPerson: "", contactNumber: "" }],
      state: "",
      city: "",
      addressLine1: "",
      addressLine2: "",
      status: "ACTIVE",
    });
    setErrors({});
  };

  /* ================= EDIT MODE ================= */
  useEffect(() => {
    if (editingTransport) {
      setFormData({
        name: editingTransport.name || "",
        email: editingTransport.email || "",
        gstNo: editingTransport.gstNo || "",
        contacts:
          editingTransport.contacts?.length > 0
            ? editingTransport.contacts
            : [{ contactPerson: "", contactNumber: "" }],
        state: editingTransport.state || "",
        city: editingTransport.city || "",
        addressLine1: editingTransport.addressLine1 || "",
        addressLine2: editingTransport.addressLine2 || "",
        status: editingTransport.status || "ACTIVE",
      });
    } else {
      resetForm();
    }
  }, [editingTransport, open]);

  /* ================= CONTACT HANDLERS ================= */
  const addContact = () => {
    setFormData((prev) => ({
      ...prev,
      contacts: [...prev.contacts, { contactPerson: "", contactNumber: "" }],
    }));
  };

  const removeContact = (index) => {
    if (index === 0) return;
    setFormData((prev) => ({
      ...prev,
      contacts: prev.contacts.filter((_, i) => i !== index),
    }));
  };

  const handleContactChange = (index, field, value) => {
    const updated = [...formData.contacts];
    updated[index][field] = value;
    setFormData((prev) => ({ ...prev, contacts: updated }));
  };

  /* ================= BASIC CHANGE ================= */
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  /* ================= VALIDATION ================= */
  const validateForm = () => {
    const newErrors = {};

    if (!formData.name.trim()) newErrors.name = "Transport name is required";

    if (formData.email && !/^\S+@\S+\.\S+$/.test(formData.email)) {
      newErrors.email = "Invalid email format";
    }

    formData.contacts.forEach((c, i) => {
      if (!c.contactNumber || !/^\d{10}$/.test(c.contactNumber)) {
        newErrors[`contact_${i}`] = "Valid 10 digit number required";
      }
    });

    if (!formData.state.trim()) newErrors.state = "State is required";
    if (!formData.city.trim()) newErrors.city = "City is required";
    if (!formData.addressLine1.trim())
      newErrors.addressLine1 = "Address is required";

    if (
      formData.gstNo &&
      !/^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/.test(
        formData.gstNo.toUpperCase()
      )
    ) {
      newErrors.gstNo = "Invalid GST number";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  /* ================= SUBMIT ================= */
  const handleSubmit = async () => {
    if (isSaving) return;

    if (!validateForm()) {
      showSnackbar("Please fix validation errors", "error");
      return;
    }

    try {
      setIsSaving(true);

      const payload = {
        name: formData.name.trim(),
        email: formData.email || null,
        gstNo: formData.gstNo || null,
        contacts: formData.contacts,
        state: formData.state,
        city: formData.city,
        addressLine1: formData.addressLine1,
        addressLine2: formData.addressLine2,
        status: formData.status,
      };

      const response = editingTransport
        ? await TransportService.updateTransport(
          editingTransport.id,
          payload
        )
        : await TransportService.createTransport(payload);

      if (!response?.success) {
        showSnackbar(response?.message || "Failed to save transport", "error");
        return;
      }

      showSnackbar(
        editingTransport
          ? "Transport updated successfully"
          : "Transport added successfully",
        "success"
      );

      onSuccess();
      resetForm();
      setOpen(false);
    } catch (e) {
      console.error(e);
      showSnackbar(e.message || "Failed to save transport", "error");
    } finally {
      setIsSaving(false);
    }
  };

  /* ================= UI ================= */
  return (
    <Dialog open={open} maxWidth="md" fullWidth>
      <DialogTitle fontWeight={600}>
        {editingTransport ? "Edit Transport" : "Add Transport"}
      </DialogTitle>

      <DialogContent>
        <Stack spacing={4}>
          {/* ===== BASIC INFO ===== */}
          <section>
            <Typography fontWeight={600} mb={1}>
              Basic Information
            </Typography>

            {/* Row 1 */}
            <Stack direction={{ xs: "column", md: "row" }} spacing={2}>
              <TextField
                label="Transport Name *"
                name="name"
                value={formData.name}
                onChange={handleChange}
                error={!!errors.name}
                helperText={errors.name}
                fullWidth
              />
              <TextField
                label="Email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                error={!!errors.email}
                helperText={errors.email}
                fullWidth
              />
            </Stack>

            {/* Row 2 */}
            <TextField
              label="GST Number"
              name="gstNo"
              value={formData.gstNo}
              onChange={handleChange}
              error={!!errors.gstNo}
              helperText={errors.gstNo}
              fullWidth
              sx={{ mt: 2 }}
            />
          </section>

          <Divider />

          {/* ===== CONTACT INFO ===== */}
          <section>
            <Typography fontWeight={600} mb={1}>
              Contact Information
            </Typography>

            {formData.contacts.map((c, index) => (
              <Box
                key={index}
                sx={{
                  p: 2,
                  mb: 1.5,
                  borderRadius: 2,
                  backgroundColor:
                    index === 0 ? "transparent" : "#f9fafb",
                  border:
                    index === 0
                      ? "none"
                      : "1px dashed #d1d5db",
                }}
              >
                <Stack direction={{ xs: "column", md: "row" }} spacing={2}>
                  <TextField
                    label="Contact Person*"
                    value={c.contactPerson}
                    onChange={(e) =>
                      handleContactChange(
                        index,
                        "contactPerson",
                        e.target.value
                      )
                    }
                    fullWidth
                  />

                  <TextField
                    label="Contact Number *"
                    value={c.contactNumber}
                    onChange={(e) => {
                      if (/^\d{0,10}$/.test(e.target.value)) {
                        handleContactChange(
                          index,
                          "contactNumber",
                          e.target.value
                        );
                      }
                    }}
                    error={!!errors[`contact_${index}`]}
                    helperText={errors[`contact_${index}`]}
                    inputProps={{ maxLength: 10 }}
                    fullWidth
                  />

                  {index > 0 && (
                    <IconButton
                      color="error"
                      onClick={() => removeContact(index)}
                    >
                      <DeleteOutlineIcon />
                    </IconButton>
                  )}
                </Stack>
              </Box>
            ))}

            <Button
              startIcon={<AddIcon />}
              onClick={addContact}
              size="small"
            >
              Add Another Contact
            </Button>
          </section>

          <Divider />

          {/* ===== ADDRESS ===== */}
          <section>
            <Typography fontWeight={600} mb={1}>
              Address
            </Typography>

            {/* Row 1 */}
            <Stack direction={{ xs: "column", md: "row" }} spacing={2}>
              <TextField
                label="State *"
                name="state"
                value={formData.state}
                onChange={handleChange}
                error={!!errors.state}
                helperText={errors.state}
                fullWidth
              />
              <TextField
                label="City *"
                name="city"
                value={formData.city}
                onChange={handleChange}
                error={!!errors.city}
                helperText={errors.city}
                fullWidth
              />
            </Stack>

            {/* Row 2 */}
            <Stack spacing={2} mt={2}>
              <TextField
                label="Address Line 1 *"
                name="addressLine1"
                value={formData.addressLine1}
                onChange={handleChange}
                error={!!errors.addressLine1}
                helperText={errors.addressLine1}
                fullWidth
              />
              <TextField
                label="Address Line 2"
                name="addressLine2"
                value={formData.addressLine2}
                onChange={handleChange}
                fullWidth
              />
            </Stack>
          </section>

          {/* ===== STATUS ===== */}
          <section>
            <Typography fontWeight={600}>Status</Typography>
            <RadioGroup
              row
              name="status"
              value={formData.status}
              onChange={handleChange}
            >
              <FormControlLabel
                value="ACTIVE"
                control={<Radio />}
                label="Active"
              />
              <FormControlLabel
                value="INACTIVE"
                control={<Radio />}
                label="Inactive"
              />
            </RadioGroup>
          </section>
        </Stack>
      </DialogContent>

      <DialogActions>
        <Button onClick={() => setOpen(false)}>Cancel</Button>
        <Button
          variant="contained"
          onClick={handleSubmit}
          disabled={isSaving}
          startIcon={isSaving && <CircularProgress size={16} />}
        >
          {editingTransport ? "Update Transport" : "Save Transport"}
        </Button>
      </DialogActions>
    </Dialog>
  );
}
