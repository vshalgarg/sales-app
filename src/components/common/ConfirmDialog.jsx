import { Dialog, DialogTitle, DialogContent, DialogActions, Button } from "@mui/material";

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
        <Button onClick={onCancel}>Stay</Button>
        <Button color="error" variant="contained" onClick={onConfirm}>
          Leave
        </Button>
      </DialogActions>
    </Dialog>
  );
}