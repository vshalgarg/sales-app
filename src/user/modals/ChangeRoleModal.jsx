import { useState } from "react";
import CustomTextField from "../../components/CustomTextField";
import { IconButton } from "@mui/material";
import Visibility from "@mui/icons-material/Visibility";
import VisibilityOff from "@mui/icons-material/VisibilityOff";
import AdminService from "../../service/AdminService";
import { useSnackbar } from "../../context/SnackbarContext";
import GenericSingleSelect from "../../components/common/GenericSingleSelect";

const roleOptions = [
  {
    id: 1,
    label: "Agent",
    value: "AGENT",
  },
  {
    id: 2,
    label: "Admin",
    value: "ADMIN",
  },
];

const ChangeRoleModal = ({ open, onClose, user,onSave }) => {
  const { showSnackbar } = useSnackbar();

  const [role,setRole]=useState(null)

  if (!open || !user) return null;


  const handleChangeRole = async () => {
   try {
      const payload={
        userId: user.id,
        role: role,
      }
      await onSave(payload)
      showSnackbar("Role updated successfully", "success");
      setRole(null);
      onClose();
    } catch (error) {
      showSnackbar(error.message || "Failed to update role", "error");  
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex justify-center items-center z-50">
      <div className="bg-white w-full max-w-md mx-4 md:mx-0 rounded-lg shadow-lg">
        <div className="px-6 py-4 border-b">
          <h2 className="text-lg font-bold">
            Change Role – {user.username}
          </h2>
        </div>

        <div className="px-6 py-4 space-y-3">
           <GenericSingleSelect
                label="Role"
                value={role}
                options={roleOptions}
                onChange={(value) => setRole(value)}
              />
        </div>

        <div className="px-6 py-3 border-t flex justify-end gap-2">
          <button
            onClick={onClose}
            className="px-3 py-2 border rounded"
          >
            Cancel
          </button>

          <button
            onClick={handleChangeRole}
            className="px-3 py-2 bg-blue-600 text-white rounded"
          >
            Submit
          </button>
        </div>
      </div>
    </div>
  );
};

export default ChangeRoleModal;
