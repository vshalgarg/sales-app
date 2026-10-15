import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Eye, Pencil, Plus, ShieldCheck, X } from "lucide-react";
import CustomTable from "../../components/CustomTable";
import { getAllRoles, getRoleData, deleteUser } from "@/services/RoleService";
import { useSnackbar } from "@/contexts/SnackbarContext";

const DetailField = ({ label, value }) => (
  <div className="flex flex-col gap-1">
    <span className="text-xs font-medium text-gray-500">
      {label}
    </span>
    <div className="rounded-md border bg-white px-3 py-2 text-sm">
      {value || "-"}
    </div>
  </div>
);

const AccessManagement = () => { 
  const navigate = useNavigate();
  const { showSnackbar } = useSnackbar();

  const [roles, setRoles] = useState([]);
  const [deleteRole, setDeleteRole] = useState(null);
  const [isDeleting, setIsDeleting] = useState(false);  
  const [selectedRole, setSelectedRole] = useState(null);
  const [openViewModal, setOpenViewModal] = useState(false);

  useEffect(() => {
    const allRoles = async () => {
      try {
        const res = await getAllRoles();
        setRoles(res);
      } catch (err) {
          showSnackbar(err?.message, 'error');
        }
    };
    allRoles();
  }, []);

  const handleViewMode = async (role) => {
    try {
      if (!role?.id) {
        showSnackbar('Role ID missing', 'error');
        return;
      }
      const res = await getRoleData(role.id);
      setSelectedRole(res);
      setOpenViewModal(true);
    } catch (err) {
        showSnackbar(err?.message, 'error');
      }
  };

  const handleRoleDelete = async () => {
    if (!deleteRole) return;

    try {
      setIsDeleting(true);
      await deleteUser(deleteRole.id);
      setRoles((prevRoles) => prevRoles.filter((role) => role.id !== deleteRole.id));

      showSnackbar("Role deleted successfully", "success");
      setDeleteRole(null);

    } catch (error) {
      showSnackbar(error?.message || "Failed to delete role", "error");
    } finally {
      setIsDeleting(false);
    }
  };

  const handleCreateRole = () => {
    navigate("/access-createrole");
  };

  const columns = [
    {
      header: "Role Name",
      accessor: "roleName",
    },
    {
      header: "Description",
      accessor: "roleDesc",
      Cell: ({ value }) => value || "-",
    },
    {
      header: "Actions",
      isAction: true,
      actions: (row) => [
        {
          label: "View",
          onClick: () => handleViewMode(row),
        },
        {
          label: "Delete",
          onClick: () => setDeleteRole(row),
        },
        {
          label: "Edit",
          onClick: () =>
            navigate("/access-editrole", { state: { id: row.id } }),
        },
      ],
    },
  ];

  return (
    <div className="h-full min-h-0 flex flex-col">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <div>
          <div className="flex items-center gap-2">
            <ShieldCheck className="text-brand-primary" size={25} />
            <h1 className="text-2xl font-bold">
              Access Management
            </h1>
          </div>

          <p className="mt-1 text-sm text-gray-500">
            Manage roles and their assigned permissions.
          </p>
        </div>

        <button
          type="button"
          onClick={handleCreateRole}
          className="inline-flex items-center gap-2 rounded-md
            bg-brand-primary px-4 py-2 text-sm font-medium text-white
            hover:opacity-90"
        >
          <Plus size={18} />
          Add New Role
        </button>
      </div>

      <div className="min-h-0 flex-1 overflow-auto rounded-lg
        border border-gray-200 bg-white shadow-sm">
        <CustomTable
          columns={columns}
          data={roles}
          emptyMessage="No roles found"
        />
      </div>

      {deleteRole && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
          onClick={() => !isDeleting && setDeleteRole(null)} >
          <div role="dialog" aria-modal="true" aria-labelledby="delete-modal-title" className="w-full max-w-md rounded-xl bg-white p-5 shadow-xl sm:p-6"
            onClick={(event) => event.stopPropagation()} >

            <div className="flex items-start gap-3">
              <div className="flex h-11 w-11 shrink-0 items-center justify-center
                rounded-full bg-red-100 text-red-600">
                <ShieldCheck size={22} />
              </div>

              <div className="flex-1">
                <h2 id="delete-modal-title" className="text-lg font-semibold text-gray-900">
                  Delete Role
                </h2>

                <p className="mt-2 text-sm leading-6 text-gray-600">
                  Are you sure you want to delete the role{" "}
                  <span className="font-semibold text-gray-900">
                    {deleteRole.roleName}
                  </span>
                </p>
              </div>

              <button
                type="button"
                onClick={() => setDeleteRole(null)}
                disabled={isDeleting}
                aria-label="Close delete confirmation"
                className="rounded-md p-1 text-gray-400 hover:bg-gray-100 hover:text-gray-600 disabled:opacity-50"
              >
                <X size={20} />
              </button>
            </div>

            <div className="mt-6 flex flex-col-reverse gap-3 sm:flex-row sm:justify-end">
              <button
                type="button"
                onClick={() => setDeleteRole(null)}
                disabled={isDeleting}
                className="rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50"
              >
                Cancel
              </button>

              <button
                type="button"
                onClick={handleRoleDelete}
                disabled={isDeleting}
                className="rounded-lg bg-red-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-red-700 disabled:cursor-not-allowed disabled:opacity-60"
              >
                {isDeleting ? "Deleting..." : "Delete Role"}
              </button>
            </div>
          </div>
        </div>
      )}

      {openViewModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <button
            type="button"
            aria-label="Close role details"
            className="absolute inset-0 bg-black/30"
            onClick={() => setOpenViewModal(false)}
          />

          <div className="relative w-full max-w-lg rounded-xl bg-white shadow-xl">
            <div className="flex items-center justify-between border-b px-6 py-4">
              <h2 className="text-lg font-semibold">
                Role Details
              </h2>

              <button
                type="button"
                aria-label="Close"
                onClick={() => setOpenViewModal(false)}
                className="rounded-md p-1 hover:bg-gray-100"
              >
                <X size={20} />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-4 p-6">
              <DetailField
                label="Role Name"
                value={selectedRole?.roleName}
              />
              <DetailField
                label="Description"
                value={selectedRole?.roleDesc}
              />
            </div>

            <div className="px-6 pb-6">
              <h3 className="mb-2 text-sm font-semibold">
                Permissions
              </h3>

              <div className="flex max-h-40 flex-wrap gap-2
                overflow-y-auto rounded-md border p-3">
                {selectedRole?.permissions?.length > 0 ? (
                  selectedRole.permissions.map((permission) => (
                    <span
                      key={permission.id}
                      className="rounded bg-gray-100 px-2 py-1 text-xs"
                    >
                      {permission.name}
                    </span>
                  ))
                ) : (
                  <span className="text-sm text-gray-400">
                    No permissions assigned
                  </span>
                )}
              </div>
            </div>

            <div className="flex justify-end border-t px-6 py-4">
              <button
                type="button"
                onClick={() => setOpenViewModal(false)}
                className="rounded-md border px-4 py-2 text-sm
                  hover:bg-gray-50"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AccessManagement;
