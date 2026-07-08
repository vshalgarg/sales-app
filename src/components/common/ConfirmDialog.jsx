import { Dialog, DialogTitle, DialogContent, DialogActions, Button } from "@mui/material";
import AppButton from "./AppButton";

export default function ConfirmDialog({
  open,
  title = "Unsaved Changes",
  message = "You have unsaved changes. Are you sure you want to leave?",
  onConfirm,
  onCancel,
}) {
  return (
    <Dialog open={open} onClose={onCancel}>
      <DialogTitle>{title}</DialogTitle>

      <DialogContent>
        <p>{message}</p>
      </DialogContent>

      <DialogActions>
        <AppButton type="cancel" onClick={onCancel}>Stay</AppButton>
        <AppButton type="primary" onClick={onConfirm}>
          Leave
        </AppButton>
      </DialogActions>
    </Dialog>
  );
}