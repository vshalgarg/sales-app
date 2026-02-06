import { useState } from "react";
import CustomTextField from "../../components/CustomTextField";
import { IconButton } from "@mui/material";
import Visibility from "@mui/icons-material/Visibility";
import VisibilityOff from "@mui/icons-material/VisibilityOff";
import { useSnackbar } from "../../context/SnackbarContext";
import { createUser } from "../../service/UserService";
import validate from "../../validations/Validation";

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

      setForm({ username: "", password: "", role: "" });
      onSuccess();
      onClose();
    } catch (error) {
      showSnackbar(error.message, "error");
    }
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
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Role
            </label>
            <select
              name="role"
              value={form.role}
              onChange={handleFormChange}
              className={`w-full border rounded-lg p-2 ${errors.role ? "border-red-500" : "border-gray-300"
                }`}
            >
              <option value="">Select role</option>
              {ROLE_OPTIONS.map((role) => (
                <option key={role} value={role}>
                  {role}
                </option>
              ))}
            </select>
            {errors.role && (
              <p className="text-xs text-red-500 mt-1">{errors.role}</p>
            )}
          </div>
        </div>

        <div className="px-6 py-2 border-t flex justify-end space-x-2">
          <button
            onClick={onClose}
            className="px-3 py-2 border rounded-lg hover:bg-gray-200 text-sm"
          >
            Cancel
          </button>
          <button
            onClick={handleAddUser}
            className="px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm"
          >
            Save User
          </button>
        </div>
      </div>
    </div>
  );
};

export default AddUserModal;
