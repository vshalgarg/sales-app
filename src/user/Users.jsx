import { useState, useEffect, useMemo } from "react";
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
import ListPagination from "../components/common/ListPagination";

import ChangePasswordModal from "./modals/ChangePasswordModal";
import AddUserModal from "./modals/AddUserModal";
import DeleteConfirmModal from "../components/common/DeleteConfirmModal";
import AppButton from "../components/common/AppButton";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";
import { CARD_GRID_SHELL_CLASS } from "../theme/cardTheme";

const Users = () => {
  const { showSnackbar } = useSnackbar();
  const { auth } = useAuth();
  const isAdmin = auth?.role?.includes("ADMIN");

  const [users, setUsers] = useState([]);
  const [query, setQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [rowsPerPage, setRowsPerPage] = useState(10);

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
      setCurrentPage(1);
    } catch (error) {
      showSnackbar(error.message, "error");
    }
  };

  const paginatedUsers = useMemo(() => {
    const start = (currentPage - 1) * rowsPerPage;
    return users.slice(start, start + rowsPerPage);
  }, [users, currentPage, rowsPerPage]);

  const handleChangePage = (newPage) => {
    const totalPages = Math.max(1, Math.ceil(users.length / rowsPerPage));
    if (newPage < 1 || newPage > totalPages) return;
    setCurrentPage(newPage);
  };

  const handleRowsPerPageChange = (newSize) => {
    setRowsPerPage(newSize);
    setCurrentPage(1);
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
    setCurrentPage(1);
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
    <div className="text-gray-900 dark:text-gray-100 flex flex-col h-full min-h-0">
      <div className="shrink-0">
        <div className="flex justify-between items-center mt-2 mb-3 gap-3">
          <h2 className={PAGE_TITLE_CLASS}>Users</h2>

          {isAdmin && (
            <AppButton type="primary" onClick={() => setIsAddUserOpen(true)}>
              <Plus size={18} className="mr-2" />
              Add New User
            </AppButton>
          )}
        </div>

        <div className="mb-3">
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
        </div>
      </div>

      <div className={`flex-1 min-h-0 flex flex-col overflow-hidden ${CARD_GRID_SHELL_CLASS}`}>
        <div className="flex-1 min-h-0 overflow-hidden p-3 md:p-4">
          <div className="h-full min-h-0">
            <DataTable
              columns={columns}
              data={paginatedUsers}
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
        </div>

        <div className="shrink-0 px-3 md:px-4 pb-3 md:pb-4">
          <ListPagination
            page={currentPage}
            totalCount={users.length}
            rowsPerPage={rowsPerPage}
            onPageChange={handleChangePage}
            onRowsPerPageChange={handleRowsPerPageChange}
            entityLabel="users"
          />
        </div>
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
