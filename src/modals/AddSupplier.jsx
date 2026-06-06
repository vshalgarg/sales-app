// src/modals/AddSupplierModal.jsx
import { useState } from "react";
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Typography,
  IconButton,
  Divider,
  Box,
  Button,
  CircularProgress,
  Grid,
} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";
import GenericAutocomplete from "../components/common/GenericAutocomplete";

const AddSupplier = ({
  open,
  onClose,
  maxWidth = "sm",
  retailerId,
  allSuppliers,
  onSave,
}) => {
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [inputs, setInputs] = useState({
    totalAmount: "",
    depositAmount: "",
  });
  const [saving, setSaving] = useState(false);

  const balance =
    (Number(inputs.totalAmount) || 0) - (Number(inputs.depositAmount) || 0);

  const handleChange = (field, value) => {
    setInputs((prev) => ({ ...prev, [field]: value }));
  };

  const handleClose = () => {
    setSelectedSupplier(null);
    setInputs({ totalAmount: "", depositAmount: "" });
    onClose();
  };

  const handleSave = async () => {
    if (!selectedSupplier || !inputs.totalAmount) return;
    try {
      setSaving(true);
      console.log("retailerId", retailerId);
      await onSave({
        retailId: retailerId,
        supplierId: selectedSupplier.id,
        totalAmount: Number(inputs.totalAmount),
        depositAmount: Number(inputs.depositAmount) || 0,
      });
      handleClose();
    } finally {
      setSaving(false);
    }
  };

  return (
    <Dialog
      open={open}
      onClose={handleClose}
      maxWidth={maxWidth}
      fullWidth
      PaperProps={{ sx: { borderRadius: 2 } }}
    >
      <DialogTitle
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          pb: 1,
        }}
      >
        <Typography variant="h6" fontWeight={600}>
          Add Supplier
        </Typography>
        <IconButton size="small" onClick={handleClose}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>

      <Divider />

      <DialogContent>
        <Box sx={{ pt: 1 }}>
          <Grid container spacing={2}>
            {/* Supplier — full width */}
            <Grid size={{ xs: 12, sm: 6 }}>
              <GenericAutocomplete
                options={allSuppliers}
                value={selectedSupplier}
                label="Supplier"
                placeholder="Select supplier"
                onChange={(value) => setSelectedSupplier(value)}
              />
            </Grid>

            {/* Total Amount */}
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField
                label="Total Amount"
                type="number"
                size="small"
                fullWidth
                value={inputs.totalAmount}
                onChange={(e) => {
                  let val = e.target.value;
                  if (/^\d*\.?\d{0,2}$/.test(val)) {
                    handleChange("totalAmount", val);
                  }
                }}
              />
            </Grid>

            {/* Deposit Amount */}
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField
                label="Deposit Amount"
                type="number"
                size="small"
                fullWidth
                value={inputs.depositAmount}
                onChange={(e) => {
                  let val = e.target.value;
                  if (/^\d*\.?\d{0,2}$/.test(val)) {
                    handleChange("depositAmount", val);
                  }
                }}
              />
            </Grid>

            {/* Balance */}
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField
                label="Balance Amount"
                size="small"
                fullWidth
                disabled
                value={balance.toFixed(2)}
              />
            </Grid>
          </Grid>
        </Box>
      </DialogContent>
      <Divider />

      <DialogActions sx={{ px: 3, py: 2, gap: 1 }}>
        <Button variant="outlined" onClick={handleClose} disabled={saving}>
          Cancel
        </Button>
        <Button
          variant="contained"
          onClick={handleSave}
          disabled={saving || !selectedSupplier || !inputs.totalAmount}
          startIcon={saving ? <CircularProgress size={16} /> : null}
        >
          {saving ? "Saving..." : "Add Supplier"}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default AddSupplier;
