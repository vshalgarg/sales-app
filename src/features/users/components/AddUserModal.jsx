import { useState } from "react";
import CustomTextField from "@/components/CustomTextField";
import { IconButton } from "@mui/material";
import Visibility from "@mui/icons-material/Visibility";
import VisibilityOff from "@mui/icons-material/VisibilityOff";
import { useSnackbar } from "@/contexts/SnackbarContext";
import { createUser } from "@/services/UserService";
import validate from "@/validations/Validation";
import {
  FormControl,
  InputLabel,
  Select,
  MenuItem,
} from "@mui/material";
import AppButton from "@/components/AppButton";


const AddUserModal = ({ open, onClose, onSuccess }) => {

  const ROLE_OPTIONS = ["ADMIN", "AGENT"];
  const { showSnackbar } = useSnackbar();

  const [showPassword, setShowPassword] = useState(false);
  const [errors, setErrors] = useState({});

  const [form, setForm] = useState({
    username: "",
    password: "",
    role: "",
  });

  if (!open) return null;

  const togglePassword = () => setShowPassword((prev) => !prev);

  const handleFormChange = (e) => {
    const { name, value } = e.target;

    setForm((prev) => ({
      ...prev,
      [name]: value,
    }));

    setErrors((prev) => ({
      ...prev,
      [name]: validate(name, value),
    }));
  };

  const handleAddUser = async (e) => {
    e.preventDefault();

    const newErrors = {};
    Object.keys(form).forEach((field) => {
      const error = validate(field, form[field]);
      if (error) newErrors[field] = error;
    });

    setErrors(newErrors);

    if (Object.keys(newErrors).length > 0) {
      showSnackbar("Please fill required fields.", "error");
      return;
    }

    const payload = {
      username: form.username,
      password: form.password,
      roles: [form.role],
    };

    try {
      const response = await createUser(payload);

      showSnackbar(response.message, "success");

      resetForm();
      onSuccess();
      onClose();
    } catch (error) {
      showSnackbar(error.message, "error");
    }
  };

  const resetForm = () => {
    setForm({
      username: "",
      password: "",
      role: "",
    });
    setErrors({});
    setShowPassword(false);
  };


  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-80 z-50">
      <div className="bg-white w-full max-w-md mx-4 md:mx-0 max-h-[50vh] rounded-lg shadow-lg flex flex-col">
        <div className="px-6 py-4 border-b">
          <h2 className="text-lg font-bold">Add New User</h2>
        </div>

        <div className="px-6 py-4 overflow-y-auto flex-1 space-y-3">
          <CustomTextField
            name="username"
            label="Username"
            value={form.username}
            onChange={handleFormChange}
            error={!!errors.username}
            helperText={errors.username || ""}
          />

          <CustomTextField
            name="password"
            label="Password"
            type={showPassword ? "text" : "password"}
            value={form.password}
            onChange={handleFormChange}
            error={!!errors.password}
            helperText={errors.password || ""}
            InputProps={{
              endAdornment: (
                <IconButton onClick={togglePassword} edge="end">
                  {showPassword ? <VisibilityOff /> : <Visibility />}
                </IconButton>
              ),
            }}
          />
          <FormControl
            fullWidth
            size="small"
            margin="dense"
            variant="outlined"
            error={!!errors.role}
          >
            <InputLabel id="role-label">Role</InputLabel>

            <Select
              labelId="role-label"
              name="role"
              value={form.role}
              label="Role"
              onChange={handleFormChange}
            >
              <MenuItem value="">
                <em>Select role</em>
              </MenuItem>

              {ROLE_OPTIONS.map((role) => (
                <MenuItem key={role} value={role}>
                  {role}
                </MenuItem>
              ))}
            </Select>

            {errors.role && (
              <p className="text-xs text-red-500 mt-1">{errors.role}</p>
            )}
          </FormControl>


        </div>

        <div className="px-6 py-2 border-t flex justify-end space-x-2">
          <button
            onClick={() => {
              resetForm();
              onClose();
            }}
            className="px-3 py-2 border rounded-lg hover:bg-gray-200 text-sm"
          >
            Cancel
          </button>
          <AppButton
            onClick={handleAddUser}
            variant="primary"
          >
            Save User
          </AppButton>
        </div>
      </div>
    </div>
  );
};

export default AddUserModal;
