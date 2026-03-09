import { Dialog, DialogTitle, DialogContent, DialogActions, Button, TextField } from "@mui/material";
import { useSnackbar } from "../../context/SnackbarContext";

export default function CopyDetailsModal({ open, onClose, title, formattedText }) {

  const { showSnackbar } = useSnackbar();

  const handleCopy = async () => {
    try {
      if (!navigator.clipboard) {
        showSnackbar("Clipboard not supported", "error");
        return;
      }

      await navigator.clipboard.writeText(formattedText);
      showSnackbar("Details copied to clipboard", "success");

    } catch (error) {
      showSnackbar("Failed to copy details", "error");
    }
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>

      <DialogTitle>{title}</DialogTitle>

      <DialogContent>
        <TextField
          fullWidth
          multiline
          rows={8}
          value={formattedText}
          variant="outlined"
        />
      </DialogContent>

      <DialogActions>
        <Button onClick={onClose}>Close</Button>

        <Button variant="contained" onClick={handleCopy}>
          Copy
        </Button>
      </DialogActions>

    </Dialog>
  );
}