import Dialog from "@mui/material/Dialog";
import DialogTitle from "@mui/material/DialogTitle";
import DialogContent from "@mui/material/DialogContent";
import DialogActions from "@mui/material/DialogActions";
import FileUploader from "./FileUploader";
import AppButton from "./AppButton";

const UploadDialog = ({
  open,
  onClose,
  files,
  setFiles,
  onSave,
  title = "Upload Files",
  maxFiles = 5,
  onError,
}) => {
  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>

      {/* HEADER */}
      <DialogTitle>{title}</DialogTitle>

      {/* BODY */}
      <DialogContent>
        <FileUploader
          value={files}
          onChange={setFiles}
          maxFiles={maxFiles}
          label={title}
          showHeader={false}
          onError={onError}
        />
      </DialogContent>

      {/* FOOTER */}
      <DialogActions sx={{ px: 3, pb: 2, gap: 1 }}>
        <AppButton type="secondary" onClick={onClose}>
          Cancel
        </AppButton>
        <AppButton type="primary" onClick={onSave}>
          Save
        </AppButton>
      </DialogActions>

    </Dialog>
  );
};

export default UploadDialog;