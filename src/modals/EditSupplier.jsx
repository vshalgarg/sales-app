// src/modals/EditSupplierModal.jsx

import { useState, useEffect } from "react";
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Typography,
  IconButton,
  Divider,
  Button,
  CircularProgress,
  Box,
} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";
import { useSnackbar } from "../context/SnackbarContext";

const EditSupplierModal = ({ open, onClose, supplier, onSave }) => {
  const [totalAmount, setTotalAmount] = useState("");
  const [saving, setSaving] = useState(false);
  const showSnackbar = useSnackbar();

  useEffect(() => {
    if (supplier) {
      setTotalAmount(supplier.totalAmount ?? "");
    }
  }, [supplier]);

  const handleClose = () => {
    setTotalAmount("");
    onClose();
  };

  const handleSave = async () => {
    if (!supplier || !totalAmount) return;

    try {
      setSaving(true);

      await onSave({
        retailSupplierId: supplier.retailSupplierId,
        totalAmount: Number(totalAmount),
      });

      handleClose();
    } catch (error) {
      showSnackbar(error.message || "something went wrong", "error");
      console.error(error);
    } finally {
      setSaving(false);
    }
  };

  return (
    <Dialog
      open={open}
      onClose={handleClose}
      maxWidth="sm"
      fullWidth
      PaperProps={{
        sx: {
          borderRadius: 2,
        },
      }}
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
          Edit Supplier
        </Typography>

        <IconButton size="small" onClick={handleClose}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>

      <Divider />

      <DialogContent sx={{ pt: 3 }}>
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: 2,
          }}
        >
          <TextField
            label="Supplier"
            value={supplier?.supplierName || ""}
            size="small"
            fullWidth
            InputProps={{
              readOnly: true,
            }}
          />

          <TextField
            label="Total Amount"
            type="number"
            size="small"
            fullWidth
            value={totalAmount}
            onChange={(e) => {
              let val = e.target.value;
              if (/^\d*\.?\d{0,2}$/.test(val)) {
                setTotalAmount(e.target.value);
              }
            }}
            inputProps={{
              min: 0,
            }}
          />
        </Box>
      </DialogContent>

      <Divider />

      <DialogActions
        sx={{
          px: 3,
          py: 2,
          gap: 1,
        }}
      >
        <Button variant="outlined" onClick={handleClose} disabled={saving}>
          Cancel
        </Button>

        <Button
          variant="contained"
          onClick={handleSave}
          disabled={saving || !totalAmount || Number(totalAmount) <= 0}
          startIcon={saving ? <CircularProgress size={16} /> : null}
        >
          {saving ? "Saving..." : "Save"}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default EditSupplierModal;
