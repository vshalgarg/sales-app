import { useEffect, useState } from "react";
import CustomTextField from "@/components/CustomTextField";
import AppButton from "@/components/AppButton";
import { useSnackbar } from "@/contexts/SnackbarContext";
import { FormControl, InputLabel, Select, MenuItem } from "@mui/material";
import { getUserById, EditUser } from "@/services/UserService";
import { getAllRoles } from "@/services/roleService";

const EditUserModal = ({ open, onClose, user, onSuccess }) => {
  const { showSnackbar } = useSnackbar();

  const [form, setForm] = useState({
    username: "",
    role: "",
  });

  const [roleOptions, setRoleOptions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (!open || !user?.id) return;

    let cancelled = false;

    const fetchDetails = async () => {
      try {
        setLoading(true);

        const [userResponse, rolesResponse] = await Promise.all([
          getUserById(user.id),
          getAllRoles(),
        ]);

        if (cancelled) return;

        const userData = userResponse?.user ?? userResponse?.data?.user ?? userResponse?.data ?? userResponse;
        const availableRoles = Array.isArray(rolesResponse)
          ? rolesResponse : rolesResponse?.data?.roles ?? rolesResponse?.data ?? rolesResponse?.roles ?? [];

        setRoleOptions(availableRoles);

        const currentRoles = Array.isArray(userData.roles)
          ? userData.roles : userData.roles ? [userData.roles] : userData.role ? [userData.role] : [];

        const currentRole = currentRoles[0];
        const currentRoleName = typeof currentRole === "string" ? currentRole : currentRole?.roleName ?? currentRole?.name ?? "";

        setForm({
          username: userData.username ?? "",
          role: currentRoleName,
        });
      } catch (error) {
        if (!cancelled) {
          showSnackbar(
            error.message || "Failed to load user details",
            "error"
          );
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    };
    fetchDetails();

    return () => {
      cancelled = true;
    };
  }, [open, user?.id]);

  if (!open || !user) return null;

  const handleRoleChange = (event) => {
    setForm((prev) => ({
      ...prev,
      role: event.target.value,
    }));
  };

    const handleSubmit = async (e) => {
    e.preventDefault();

    if (!form.role) {
        showSnackbar("Please select a role", "error");
        return;
    }

    try {
        setSaving(true);
        await EditUser(user.id, {
        roleNames: [form.role],
        });

        showSnackbar("User role updated successfully", "success");
        await onSuccess?.();
        onClose();
    } catch (error) {
        showSnackbar(
        error.message || "Failed to update user role",
        "error"
        );
    } finally {
        setSaving(false);
    }
    };

  return (
    <div className="fixed inset-0 bg-black/50 flex justify-center items-center z-50 p-4">
      <div className="bg-white w-full max-w-md rounded-lg shadow-lg">
        <div className="px-6 py-4 border-b">
          <h2 className="text-lg font-bold">Edit User</h2>
        </div>

        <form autoComplete="off">
          <div className="px-6 py-4 space-y-4">
            {loading ? (
              <p className="text-sm text-gray-500">
                Loading user details and roles...
              </p>
            ) : (
              <>
                <CustomTextField
                  label="Username"
                  name="edit-username"
                  type="text"
                  value={form.username}
                  InputProps={{ readOnly: true }}
                />

                <FormControl fullWidth size="small" variant="outlined">
                  <InputLabel id="edit-role-label">Role</InputLabel>

                  <Select
                    labelId="edit-role-label"
                    id="edit-user-role"
                    name="role"
                    value={form.role}
                    label="Role"
                    onChange={handleRoleChange}
                    disabled={saving}
                  >
                    <MenuItem value="">
                      Select role
                    </MenuItem>

                    {roleOptions.map((role) => (
                      <MenuItem
                        key={role.id ?? role.roleId ?? role.roleName}
                        value={role.roleName}
                      >
                        {role.roleName}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </>
            )}
          </div>

          <div className="px-6 py-3 flex justify-end gap-2">
            <button
              type="button"
              onClick={onClose}
              disabled={saving}
              className="px-3 py-2 border rounded disabled:opacity-50"
            >
              Cancel
            </button>

            <AppButton
              type="submit"
              variant="primary"
              disabled={loading || saving}
              onClick={handleSubmit}
            >
              {saving ? "Saving..." : "Save Changes"}
            </AppButton>
          </div>
        </form>
      </div>
    </div>
  );
};

export default EditUserModal;
