import Dialog from "@mui/material/Dialog";
import DialogTitle from "@mui/material/DialogTitle";
import DialogContent from "@mui/material/DialogContent";
import DialogActions from "@mui/material/DialogActions";
import FileUploader from "./FileUploader";

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
      <DialogActions sx={{ px: 3, pb: 2 }}>
        <button
          onClick={onClose}
          className="px-4 py-2 text-sm border rounded-lg hover:bg-gray-100"
        >
          Cancel
        </button>

        <button
          onClick={onSave}
          className="px-5 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          Save
        </button>
      </DialogActions>

    </Dialog>
  );
};

export default UploadDialog;