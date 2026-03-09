import { Dialog, DialogTitle, DialogContent, DialogActions, Button, TextField } from "@mui/material";
import { useSnackbar } from "../context/SnackbarContext";

export default function CopyCustomerModal({ open, onClose, customer }) {

    const { showSnackbar } = useSnackbar();
    const formattedText = `Firm Name: ${customer?.customerName || "-"}
Address: ${customer?.address || "-"}
Phone No: ${customer?.contacts?.[0]?.mobileNumber || "-"}
GST No: ${customer?.customerGstNo || "-"}`;

    const handleCopy = () => {
        navigator.clipboard.writeText(formattedText);
        showSnackbar("Customer details copied", "success");
    };

    return (
        <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>

            <DialogTitle>
                Copy Customer Details
            </DialogTitle>

            <DialogContent>
                <TextField
                    fullWidth
                    multiline
                    rows={6}
                    value={formattedText}
                    variant="outlined"
                />
            </DialogContent>

            <DialogActions>
                <Button onClick={onClose}>
                    Close
                </Button>

                <Button
                    variant="contained"
                    onClick={handleCopy}
                >
                    Copy
                </Button>
            </DialogActions>

        </Dialog>
    );
}