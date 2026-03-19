import { Dialog, DialogTitle, DialogContent, DialogActions, Button } from "@mui/material";
import { useSnackbar } from "../../context/SnackbarContext";
import { useState } from "react";
import { convertHtmlToWhatsApp } from "../../utils/copyFormatter";

export default function CopyDetailsModal({ open, onClose, title, formattedText }) {

  const { showSnackbar } = useSnackbar();
  const [copying, setCopying] = useState(false);

  const handleCopy = async () => {

    if (!formattedText) {
      showSnackbar("No data to copy", "warning");
      return;
    }
    setCopying(true);

    try {
      if (navigator.clipboard?.write && window.ClipboardItem) {
        await navigator.clipboard.write([
          new ClipboardItem({
            "text/html": new Blob([formattedText.html], { type: "text/html" }),
            "text/plain": new Blob([
              convertHtmlToWhatsApp(formattedText.html)
            ], { type: "text/plain" })
          })
        ]);

      } else {
        await navigator.clipboard.writeText(
          convertHtmlToWhatsApp(formattedText.html)
        );
      }

      showSnackbar("Details copied to clipboard", "success");
      onClose();
    } catch (error) {
      showSnackbar("Failed to copy details", "error");
    } finally {
      setCopying(false);
    }
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>

      <DialogTitle>{title}</DialogTitle>

      <DialogContent>

        {/* UI Preview */}
        <div
          style={{
            border: "1px solid #ddd",
            padding: "12px",
            borderRadius: "6px",
            background: "#fafafa",
            lineHeight: "1.8"
          }}
          dangerouslySetInnerHTML={{ __html: formattedText?.html }}
        />

      </DialogContent>

      <DialogActions>

        <Button onClick={onClose}>
          Close
        </Button>

        <Button variant="contained" onClick={handleCopy} disabled={copying}>
          {copying ? "Copying..." : "Copy"}
        </Button>

      </DialogActions>

    </Dialog>
  );
}