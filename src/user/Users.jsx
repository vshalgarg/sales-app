import { useState, useEffect } from "react";
import { Plus } from "lucide-react";
import {
  getUsers,
  deleteUser,
  searchUsers,
} from "../service/UserService";
import { useSnackbar } from "../context/SnackbarContext";
import { useAuth } from "../context/AuthContext";

import DataTable from "../components/DataTable";
import UniversalSearch from "../components/UniversalSearch";

import ChangePasswordModal from "./modals/ChangePasswordModal";
import AddUserModal from "./modals/AddUserModal";
import DeleteConfirmModal from "../components/common/DeleteConfirmModal";

const Users = () => {
  const { showSnackbar } = useSnackbar();
  const { auth } = useAuth();
  const isAdmin = auth?.role?.includes("ADMIN");

  const [users, setUsers] = useState([]);
  const [query, setQuery] = useState("");

  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [userToDelete, setUserToDelete] = useState(null);

  const [changePwdModalOpen, setChangePwdModalOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);

  const [isAddUserOpen, setIsAddUserOpen] = useState(false);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const data = await getUsers();
      setUsers(data.users);
    } catch (error) {
      showSnackbar(error.message, "error");
    }
  };

  const handleSearchResult = (response, searchQuery) => {
    if (!searchQuery.trim()) {
      fetchUsers();
      return;
    }

    if (Array.isArray(response)) {
      setUsers(response);
    } else {
      setUsers(response.content || []);
    }
  };


  const handleDelete = async () => {
    if (!userToDelete?.id) return;

    try {
      await deleteUser(userToDelete.id);
      showSnackbar("User deleted successfully", "success");
      fetchUsers();
    } catch (error) {
      showSnackbar(error.message, "error");
    } finally {
      setDeleteModalOpen(false);
      setUserToDelete(null);
    }
  };

  const columns = [
    {
      key: "username",
      label: "Username",
      width: "70%",
    },
  ];

  return (
    <div className="text-gray-900 dark:text-gray-100 flex flex-col h-full">
      {/* HEADER */}
      <div className="pt-4 flex justify-between items-center mb-4">
        <h1 className="text-2xl font-bold">Users</h1>

        {isAdmin && (
          <button
            onClick={() => setIsAddUserOpen(true)}
            className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            <Plus size={18} className="mr-2" />
            Add New User
          </button>
        )}
      </div>

      {/* SEARCH */}
      <UniversalSearch
        placeholder="Search users..."
        query={query}
        setQuery={setQuery}
        searchFn={searchUsers}
        onResult={handleSearchResult}
        onClear={fetchUsers}
        suggestionKey="username"
        showSuggestions={false}
      />

      {/* TABLE */}
      <div className="flex-1 mt-4">
        <DataTable
          columns={columns}
          data={users}
          loading={false}
          actions={isAdmin}
          onEdit={isAdmin ? (u) => {
            setSelectedUser(u);
            setChangePwdModalOpen(true);
          } : undefined}
          onDelete={isAdmin ? (u) => {
            setUserToDelete(u);
            setDeleteModalOpen(true);
          } : undefined}
          emptyMessage="No users found"
          disablePagination
        />
      </div>

      {/* MODALS */}
      <AddUserModal
        open={isAddUserOpen}
        onClose={() => setIsAddUserOpen(false)}
        onSuccess={fetchUsers}
      />

      <ChangePasswordModal
        open={changePwdModalOpen}
        user={selectedUser}
        onClose={() => {
          setChangePwdModalOpen(false);
          setSelectedUser(null);
        }}
      />

      <DeleteConfirmModal
        open={deleteModalOpen}
        title="Delete User"
        message={
          <>
            Are you sure you want to delete{" "}
            <b>{userToDelete?.username}</b>?
            This action cannot be undone.
          </>
        }
        confirmText="Delete"
        cancelText="Cancel"
        onClose={() => {
          setDeleteModalOpen(false);
          setUserToDelete(null);
        }}
        onConfirm={handleDelete}
      />

    </div>
  );
};

export default Users;
