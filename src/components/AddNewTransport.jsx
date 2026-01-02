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
} from "@mui/material";
import { Close as CloseIcon } from "@mui/icons-material";
import TransportService from "../service/TransportService";
import { useSnackbar } from "../context/SnackbarContext";

export default function AddNewTransport({
  open,
  setOpen,
  editingTransport = null,
  onSuccess,
}) {
  const { showSnackbar } = useSnackbar();

  const [formData, setFormData] = useState({
    name: "",
    gstNo: "",
    contactNumber: "",
    city: "",
    address: "",
    status: "ACTIVE",
  });

  const [isSaving, setIsSaving] = useState(false);
  const [errors, setErrors] = useState({});

  // ---------- RESET ----------
  const resetForm = () => {
    setFormData({
      name: "",
      gstNo: "",
      contactNumber: "",
      city: "",
      address: "",
      status: "ACTIVE",
    });
    setErrors({});
  };

  // ---------- EDIT MODE ----------
  useEffect(() => {
    if (editingTransport) {
      setFormData({
        name: editingTransport.name || "",
        gstNo: editingTransport.gstNo || "",
        contactNumber: editingTransport.contactNumber || "",
        city: editingTransport.city || "",
        address: editingTransport.address || "",
        status: editingTransport.status || "ACTIVE",
      });
    } else {
      resetForm();
    }
  }, [editingTransport, open]);

  // ---------- VALIDATION ----------
  const validateForm = () => {
    const newErrors = {};

    if (!formData.name.trim()) {
      newErrors.name = "Transport name is required";
    }

    if (formData.contactNumber && !/^\d{10}$/.test(formData.contactNumber)) {
      newErrors.contactNumber = "Enter valid 10-digit number";
    }

    if (
      formData.gstNo &&
      !/^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/.test(
        formData.gstNo.toUpperCase()
      )
    ) {
      newErrors.gstNo = "Enter valid GST number (15 characters)";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  // ---------- handleChange ----------
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));

    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: "" }));
    }
  };

  // ---------- SUBMIT (REUSABLE) ----------
  const handleSubmit = async ({ closeAfterSave }) => {
    if (isSaving) return;

    if (!validateForm()) {
      showSnackbar("Please fix validation errors", "error");
      return;
    }

    try {
      setIsSaving(true);

      const payload = {
        name: formData.name.trim(),
        gstNo: formData.gstNo.trim(),
        contactNumber: formData.contactNumber.trim(),
        city: formData.city.trim(),
        address: formData.address.trim(),
        status: formData.status,
      };

      const response = editingTransport
        ? await TransportService.updateTransport({
          id: editingTransport.id,
          ...payload,
        })
        : await TransportService.createTransport(payload);

      if (!response?.success) {
        showSnackbar(response?.message || "Failed to save transport", "error");
        return;
      }

      showSnackbar(
        editingTransport ? "Transport updated successfully" : "Transport added successfully",
        "success"
      );

      onSuccess();
      resetForm();

      if (closeAfterSave) {
        setOpen(false);
      }
    } catch (err) {
      console.error(err);
      showSnackbar("Failed to save transport", "error");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <Dialog
      open={open}
      onClose={() => !isSaving && setOpen(false)}
      maxWidth="sm"
      fullWidth
      PaperProps={{
        sx: {
          borderRadius: 3,
          boxShadow: "0 12px 40px rgba(0,0,0,0.12)",
        },
      }}
    >
      {/* ================= HEADER ================= */}
      <DialogTitle sx={{ px: 3, py: 2, borderBottom: "1px solid #eee", backgroundColor: "#fafafa", borderBottom: "1px solid #e5e7eb", }}>
        <div className="flex justify-between items-center">
          <div>
            <Typography fontWeight={600}>
              {editingTransport ? "Edit Transport" : "Add Transport"}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              Transport basic and contact details
            </Typography>
          </div>

          <CloseIcon
            onClick={() => !isSaving && setOpen(false)}
            className="cursor-pointer text-gray-500 hover:text-black"
          />
        </div>
      </DialogTitle>

      {/* ================= CONTENT ================= */}
      <DialogContent sx={{ px: 3, py: 3 }}>
        <Stack spacing={3}>

          {/* -------- BASIC INFO -------- */}
          <div>
            <Typography fontSize={14} fontWeight={600} mb={1} mt={1}>
              Basic Information
            </Typography>

            <TextField
              label="Transport Name *"
              name="name"
              value={formData.name}
              onChange={handleChange}
              error={!!errors.name}
              helperText={errors.name}
              fullWidth
              size="small"
            />
          </div>

          {/* -------- CONTACT INFO -------- */}
          <div>
            <Typography fontSize={14} fontWeight={600} mb={1}>
              Contact Details
            </Typography>

            <Stack direction="row" spacing={2}>
              <TextField
                label="GST Number"
                name="gstNo"
                value={formData.gstNo}
                onChange={handleChange}
                fullWidth
                size="small"
                error={!!errors.gstNo}
                helperText={errors.gstNo}
              />

              <TextField
                label="Contact Number"
                name="contactNumber"
                value={formData.contactNumber}
                onChange={handleChange}
                error={!!errors.contactNumber}
                helperText={errors.contactNumber}
                fullWidth
                size="small"
              />
            </Stack>
          </div>

          {/* -------- ADDRESS -------- */}
          <div>
            <Typography fontSize={14} fontWeight={600} mb={1}>
              Address
            </Typography>

            <Stack spacing={1.5}>

              <TextField
                label="City"
                name="city"
                value={formData.city}
                onChange={handleChange}
                fullWidth
                size="small"
              />
              <TextField
                label="Address Line 1"
                name="address"
                value={formData.address}
                onChange={handleChange}
                fullWidth
                size="small"
              />

              <TextField
                label="Address Line 2"
                name="addressLine2"
                placeholder="Landmark / Area (optional)"
                fullWidth
                size="small"
              />
            </Stack>
          </div>

          {/* -------- STATUS -------- */}
          <div>
            <Typography fontSize={14} fontWeight={600} mb={0.5}>
              Status
            </Typography>

            <RadioGroup
              row
              name="status"
              value={formData.status}
              onChange={handleChange}
            >
              <FormControlLabel
                value="ACTIVE"
                control={<Radio size="small" />}
                label="Active"
              />
              <FormControlLabel
                value="INACTIVE"
                control={<Radio size="small" />}
                label="Inactive"
              />
            </RadioGroup>
          </div>

        </Stack>
      </DialogContent>

      {/* ================= FOOTER ================= */}
      <DialogActions
        sx={{
          px: 3,
          py: 2,
          borderTop: "1px solid #eee",
          background: "#fafafa",
        }}
      >
        <Button
          disabled={isSaving}
          onClick={() => setOpen(false)}
          size="small"
        >
          Cancel
        </Button>

        {/* ONLY IN ADD MODE */}
        {!editingTransport && (
          <Button
            disabled={isSaving}
            variant="outlined"
            size="small"
            onClick={() => handleSubmit({ closeAfterSave: false })}
            startIcon={isSaving && <CircularProgress size={14} />}
          >
            Save & Add New
          </Button>
        )}

        {/* SAVE / UPDATE */}
        <Button
          disabled={isSaving}
          variant="contained"
          size="small"
          onClick={() => handleSubmit({ closeAfterSave: true })}
          startIcon={isSaving && <CircularProgress size={14} />}
        >
          {editingTransport ? "Update Transport" : "Save Transport"}
        </Button>
      </DialogActions>
    </Dialog>
  );

}
