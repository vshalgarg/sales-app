import { useState, useEffect, useRef } from "react";
import { Trash2, Plus } from "lucide-react";
import {
  createUser,
  getUsers,
  deleteUser,
  searchUsers,
} from "../service/UserService";
import CustomTextField from "./CustomTextField";
import { IconButton } from "@mui/material";
import { Visibility, VisibilityOff } from "@mui/icons-material";
import { useSnackbar } from "../context/SnackbarContext";
import validate from "../validations/Validation";

const Users = () => {
  const { showSnackbar } = useSnackbar();
  const [users, setUsers] = useState([]);
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const searchRef = useRef(null);
  const roles = ["AGENT"];
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [errors, setErrors] = useState({});
  const [form, setForm] = useState({
    username: "",
    password: "",
    roles: roles,
  });
  // 🔹 Delete modal states
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [userToDelete, setUserToDelete] = useState(null);

  const togglePassword = () => setShowPassword((prev) => !prev);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (searchRef.current && !searchRef.current.contains(e.target)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const data = await getUsers();
      setUsers(data.users);
    } catch (error) {
      showSnackbar(error.message)
    }
  };

  // ✅ Handle input & live search
  const handleInputChange = async (e) => {
    const value = e.target.value;
    setQuery(value);
    if (!value.trim()) {
      setSuggestions([]);
      fetchUsers();
      return;
    }
    if (value.length > 1) {
      try {
        const result = await searchUsers(value);
        // ✅ Backend returns a list of objects
        setSuggestions(result || []);
        setIsDropdownOpen(true);
      } catch (error) {
        setSuggestions([]);
        showSnackbar(error.message)
      }
    } else {
      setSuggestions([]);
    }
  };

  // ✅ When user clicks a suggestion
  const handleSuggestionClick = (user) => {
    setQuery(user.username);
    setSuggestions([]);
    setUsers([user]); // directly show selected user
    setIsDropdownOpen(false);
  };

  const confirmDelete = (user) => {
    setUserToDelete(user);
    setDeleteModalOpen(true);
  };

  const handleDelete = async () => {
  if (!userToDelete?.id) return;

  try {
    const response = await deleteUser(userToDelete.id);

    showSnackbar(
      response?.message || "User deactivated successfully",
      "success"
    );

    fetchUsers();
  } catch (error) {
    showSnackbar(error.message || "Error deleting user", "error");
  } finally {
    setDeleteModalOpen(false);
    setUserToDelete(null);
  }
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
    try {
      const response = await createUser(form);

     showSnackbar(response.message, "success");
        setForm({ username: "", password: "", roles: roles });
        fetchUsers();
    } catch (error) {
      console.error("Error creating user:", error);
      showSnackbar(error.message, "error");
    }finally {
    setIsModalOpen(false);
  }
  };

  const handleFormChange = (e) => {
    const { name, value } = e.target;
    setForm({ ...form, [name]: value });
    setErrors((prev) => ({ ...prev, [name]: validate(name, value) }));
  };

  return (
    <div className="text-gray-900 dark:text-gray-100">
      {/* Header */}
       <div className="pt-4">
      <div className="flex items-center justify-between mb-2">
        <h1 className="text-2xl font-bold">Users</h1>
        <button
          className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700"
          onClick={() => setIsModalOpen(true)}
        >
          <Plus size={18} className="mr-2" />
          Add New User
        </button>
      </div>
      </div>
       
      {/* Search input */}
      <div ref={searchRef} className="relative w-1/2">
        <input
          type="text"
          value={query}
          onChange={handleInputChange}
          onFocus={() => setIsDropdownOpen(true)}
          placeholder="Search users..."
          className="w-full border rounded-lg p-2"
        />
        {isDropdownOpen && suggestions.length > 0 && (
          <ul className="absolute bg-white border rounded-lg shadow-md w-full mt-1 z-10">
            {suggestions.map((s, idx) => (
              <li
                key={idx}
                className="p-2 hover:bg-gray-100 cursor-pointer"
                onClick={() => handleSuggestionClick(s)}
              >
                {s.username}
              </li>
            ))}
          </ul>
        )}
      </div>
              
      {/* Table */}
      <div className="relative mt-6 rounded-lg shadow bg-white">
        <table className="min-w-full table-auto text-sm text-left">
          <thead className="bg-gray-100 text-gray-700 uppercase text-xs">
            <tr>
              
              <th className="px-6 py-3">Username</th>
              <th className="px-6 py-3">Action</th>
            </tr>
          </thead>
          <tbody>
            {users.length > 0 ? (
              users.map((u, i) => (
                <tr key={i} className="border-t hover:bg-gray-50 relative">
                  
                  <td className="px-6 py-2">{u.username}</td>
                  <td>
                    <button
                      onClick={() => confirmDelete(u)}
                      className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
                    >
                      <Trash2 className="w-5 h-5 text-red-600" />
                    </button>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="8" className="text-center text-gray-500 py-4">
                  No User found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Add User Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-80 z-50">
          <div className="bg-white w-full max-w-md max-h-[50vh] rounded-lg shadow-lg flex flex-col">
            <div className="px-6 py-4 border-b">
              <h2 className="text-lg font-bold">Add New User</h2>
            </div>

            <div className="px-6 py-4 overflow-y-auto flex-1 space-y-3">
              <CustomTextField
                name="username"
                value={form.username}
                onChange={handleFormChange}
                label="Username"
                error={!!errors.username}
                helperText={errors.username || ""}
              />

              <CustomTextField
                name="password"
                value={form.password}
                onChange={handleFormChange}
                label="Password"
                type={showPassword ? "text" : "password"}
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
            </div>

            <div className="px-6 py-2 border-t flex justify-end space-x-2">
              <button
                onClick={() => {
                  setIsModalOpen(false);
                  setErrors({});
                  setForm({ username: "", password: "", roles: roles });
                }}
                className="px-3 py-2 border rounded-lg hover:bg-gray-200 text-sm"
              >
                Cancel
              </button>
              <button
                type="submit"
                onClick={handleAddUser}
                className="px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm"
              >
                Save User
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {deleteModalOpen && userToDelete && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50">
          <div className="bg-white dark:bg-zinc-900 rounded-2xl shadow-2xl w-[380px] p-6 transform transition-all animate-fadeIn">
            <div className="flex items-center justify-center mb-4">
              <div className="bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 rounded-full p-3">
                <Trash2 className="w-6 h-6" />
              </div>
            </div>

            <h3 className="text-lg font-semibold text-center text-gray-800 dark:text-gray-100 mb-2">
              Delete User
            </h3>
            <p className="text-center text-gray-600 dark:text-gray-400 text-sm mb-6">
              Are you sure you want to permanently delete{" "}
              <span className="font-medium text-blue-600 dark:text-blue-400">
                {userToDelete?.username}
              </span>
              ? This action cannot be undone.
            </p>

            <div className="flex justify-center gap-3">
              <button
                onClick={() => setDeleteModalOpen(false)}
                className="px-4 py-2 rounded-lg border border-gray-300 dark:border-zinc-700 
                             text-gray-700 dark:text-gray-200 hover:bg-gray-100 
                             dark:hover:bg-zinc-800 transition-all duration-150"
              >
                Cancel
              </button>
              <button
                onClick={handleDelete}
                className="px-4 py-2 rounded-lg bg-red-600 text-white hover:bg-red-700 
                             shadow-sm transition-all duration-150"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Users;
