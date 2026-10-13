import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Eye, Pencil, Plus, ShieldCheck, X } from "lucide-react";
import CustomTable from "../../components/CustomTable";

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

function AccessManagement() {
  const navigate = useNavigate();

  // Connect this state to your roles API.
  const [roles] = useState([]);
  const [selectedRole, setSelectedRole] = useState(null);
  const [openViewModal, setOpenViewModal] = useState(false);

  const handleView = (role) => {
    // Replace with getRoleDetails(role.id) when
    // the roles service is connected.
    setSelectedRole(role);
    setOpenViewModal(true);
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
          onClick: () => handleView(row),
        },
        {
          label: "Delete",
          onClick: () => handleView(row),
        },
        {
          label: "Edit",
          onClick: () =>
            navigate("/access/role/edit", { state: { id: row.id } }),
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
          onClick={() => navigate("/access/role/create")}
          className="inline-flex items-center gap-2 rounded-md
            bg-brand-primary px-4 py-2 text-sm font-medium text-white
            hover:opacity-90"
        >
          <Plus size={18} />
          Create Role
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

      {openViewModal && (
        <div className="fixed inset-0 z-50 flex items-center
          justify-center p-4">
          <button
            type="button"
            aria-label="Close role details"
            className="absolute inset-0 bg-black/30"
            onClick={() => setOpenViewModal(false)}
          />

          <div className="relative w-full max-w-lg rounded-xl
            bg-white shadow-xl">
            <div className="flex items-center justify-between
              border-b px-6 py-4">
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
              <DetailField
                label="Reporting To"
                value={selectedRole?.parentRoleName}
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
