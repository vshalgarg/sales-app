import { useState } from "react";
import CustomTextField from "../../components/CustomTextField";
import { IconButton } from "@mui/material";
import Visibility from "@mui/icons-material/Visibility";
import VisibilityOff from "@mui/icons-material/VisibilityOff";
import AppButton from "../../components/common/AppButton";
import AdminService from "../../service/AdminService";
import { useSnackbar } from "../../context/SnackbarContext";

const ChangePasswordModal = ({ open, onClose, user }) => {
  const { showSnackbar } = useSnackbar();

  const [showPassword, setShowPassword] = useState(false);
  const [passwordForm, setPasswordForm] = useState({
    password: "",
    confirmPassword: "",
  });

  if (!open || !user) return null;

  const togglePassword = () => setShowPassword((prev) => !prev);

  const handleChangePassword = async () => {
    if (!passwordForm.password || !passwordForm.confirmPassword) {
      showSnackbar("All fields are required", "error");
      return;
    }

    if (passwordForm.password !== passwordForm.confirmPassword) {
      showSnackbar("Passwords do not match", "error");
      return;
    }

    try {
      await AdminService.changeUserPassword({
        userId: user.id,
        newPassword: passwordForm.password,
      });

      showSnackbar("Password updated successfully", "success");
      setPasswordForm({ password: "", confirmPassword: "" });
      onClose();
    } catch (error) {
      showSnackbar(error.message || "Failed to update password", "error");
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex justify-center items-center z-50">
      <div className="bg-white w-full max-w-md mx-4 md:mx-0 rounded-lg shadow-lg">
        <div className="px-6 py-4 border-b">
          <h2 className="text-lg font-bold">
            Change Password – {user.username}
          </h2>
        </div>

        <div className="px-6 py-4 space-y-3">
          <CustomTextField
            label="New Password"
            type={showPassword ? "text" : "password"}
            value={passwordForm.password}
            onChange={(e) =>
              setPasswordForm({ ...passwordForm, password: e.target.value })
            }
            InputProps={{
              endAdornment: (
                <IconButton onClick={togglePassword} edge="end">
                  {showPassword ? <VisibilityOff /> : <Visibility />}
                </IconButton>
              ),
            }}
          />

          <CustomTextField
            label="Confirm Password"
            type={showPassword ? "text" : "password"}
            value={passwordForm.confirmPassword}
            onChange={(e) =>
              setPasswordForm({
                ...passwordForm,
                confirmPassword: e.target.value,
              })
            }
            InputProps={{
              endAdornment: (
                <IconButton onClick={togglePassword} edge="end">
                  {showPassword ? <VisibilityOff /> : <Visibility />}
                </IconButton>
              ),
            }}
          />
        </div>

        <div className="px-6 py-3 border-t flex justify-end gap-2">
          <button
            onClick={onClose}
            className="px-3 py-2 border rounded"
          >
            Cancel
          </button>

          <AppButton
            onClick={handleChangePassword}
            variant="primary"
          >
            Update Password
          </AppButton>
        </div>
      </div>
    </div>
  );
};

export default ChangePasswordModal;
