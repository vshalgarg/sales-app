import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, ChevronLeft, ChevronRight, LoaderCircle, Search } from "lucide-react";
import CustomTextField from "@/components/CustomTextField";
import { createRole } from "@/services/roleService";
import { getAllPermission } from "@/services/PermissionService";
import { useSnackbar } from "@/contexts/SnackbarContext";

const normalizePermissions = (response) => {
  const list = Array.isArray(response)
    ? response
    : response?.data ?? response?.permissions ?? [];

  return list.map((permission) => ({
    id: permission.id ?? permission.permissionId,
    name: permission.name ?? permission.permissionName,
    description:
      permission.description ?? permission.desc ?? "",
  }));
};

const CreateRole = () => {
  const navigate = useNavigate();
  const { showSnackbar } = useSnackbar();

  const [roleName, setRoleName] = useState("");
  const [description, setDescription] = useState("");

  const [availablePermissions, setAvailablePermissions] = useState([]);
  const [assignedPermissions, setAssignedPermissions] = useState([]);

  const [selectedAvailable, setSelectedAvailable] = useState([]);
  const [selectedAssigned, setSelectedAssigned] = useState([]);

  const [searchAvailable, setSearchAvailable] = useState("");
  const [searchAssigned, setSearchAssigned] = useState("");

  const [errors, setErrors] = useState({});
  const [loadingPermissions, setLoadingPermissions] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    let active = true;

    const getPermissions = async () => {
      try {
        const response = await getAllPermission();

        if (active) {
          setAvailablePermissions(normalizePermissions(response));
        }
      } catch (error) {
        if (active) {
          showSnackbar(
            error?.message || "Failed to load permissions",
            "error"
          );
        }
      } finally {
        if (active) {
          setLoadingPermissions(false);
        }
      }
    };

    getPermissions();

    return () => {
      active = false;
    };
  }, [showSnackbar]);

  const filteredAvailable = useMemo(
    () =>
      availablePermissions.filter((permission) =>
        permission.name
          ?.toLowerCase()
          .includes(searchAvailable.toLowerCase())
      ),
    [availablePermissions, searchAvailable]
  );

  const filteredAssigned = useMemo(
    () =>
      assignedPermissions.filter((permission) =>
        permission.name
          ?.toLowerCase()
          .includes(searchAssigned.toLowerCase())
      ),
    [assignedPermissions, searchAssigned]
  );

  const togglePermission = (permission, side) => {
    const setter = side === "available" ? setSelectedAvailable : setSelectedAssigned;

    setter((previous) =>
      previous.some((item) => item.id === permission.id)
        ? previous.filter((item) => item.id !== permission.id)
        : [...previous, permission]
    );
  };

  const moveRight = () => {
    if (!selectedAvailable.length) return;

    const movingIds = new Set(selectedAvailable.map((permission) => permission.id));

    setAssignedPermissions((previous) => [
      ...previous,
      ...selectedAvailable,
    ]);

    setAvailablePermissions((previous) =>
      previous.filter((permission) => !movingIds.has(permission.id)));

    setSelectedAvailable([]);
  };

  const moveLeft = () => {
    if (!selectedAssigned.length) return;

    const movingIds = new Set(selectedAssigned.map((permission) => permission.id));

    setAvailablePermissions((previous) => [
      ...previous,
      ...selectedAssigned,
    ]);

    setAssignedPermissions((previous) =>
      previous.filter((permission) => !movingIds.has(permission.id)));

    setSelectedAssigned([]);
  };

  const moveAllRight = () => {
    setAssignedPermissions((previous) => [
      ...previous,
      ...availablePermissions,
    ]);
    setAvailablePermissions([]);
    setSelectedAvailable([]);
  };

  const moveAllLeft = () => {
    setAvailablePermissions((previous) => [
      ...previous,
      ...assignedPermissions,
    ]);
    setAssignedPermissions([]);
    setSelectedAssigned([]);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    const nextErrors = {};

    if (!roleName.trim()) {
      nextErrors.roleName = "Role name is required";
    }

    setErrors(nextErrors);
    if (Object.keys(nextErrors).length > 0) return;

    const payload = {
      roleName: roleName.trim(),
      roleDesc: description.trim(),
      permissionIds: assignedPermissions.map((permission) =>
        Number(permission.id)
      ),
    };

    try {
      setSaving(true);

      const response = await createRole(payload);
      showSnackbar( response?.message || "Role created successfully", "success");
      navigate("/access-management");
    } catch (error) {
      showSnackbar(
        error?.message || "Failed to create role",
        "error"
      );
    } finally {
      setSaving(false);
    }
  };


    const renderPermissionList = ({
    title,
    isAssigned,
    items,
    search,
    setSearch,
    selected,
    side,
    }) => (
    <section
        className={`flex h-[320px] min-w-0 flex-col rounded-xl border p-4 sm:h-[380px] ${
        isAssigned ? "border-green-200" : "border-gray-300"}`}
    >
        {/* Panel heading */}
        <h2 className={`mb-0 shrink-0 text-base font-semibold sm:text-lg ${ isAssigned ? "text-green-700" : "text-gray-800"}`}>
        {title} ({items.length})
        </h2>

        <p className="shrink-0 text-xs text-gray-700">
        Select permissions to {isAssigned ? "remove" : "assign"}.
        </p>
            

        {/* Search field */}
        <div className="relative mb-3 shrink-0 pt-1">
        <Search size={17} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"/>

        <input
            type="search"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            placeholder="Search the role"
            aria-label={`Search ${title}`}
            className="w-full rounded-lg border border-gray-300 py-2.5 pl-9 pr-3 text-sm outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
        />
        </div>

        {/* Scrollable permissions */}
        <div className="min-h-0 flex-1 overflow-y-auto space-y-1 pr-1">
        {loadingPermissions ? (
            <div className="flex h-32 items-center justify-center text-sm text-gray-500">
            <LoaderCircle
                className="mr-2 animate-spin"
                size={18}
            />
            Loading permissions...
            </div>
        ) : items.length > 0 ? (
            items.map((permission) => {
            const isSelected = selected.some(
                (item) => item.id === permission.id
            );

            return (
                <button
                key={permission.id}
                type="button"
                title={permission.description || permission.name}
                onClick={() => togglePermission(permission, side)}
                aria-pressed={isSelected}
                className={`w-full break-words rounded-md px-3 py-2.5 text-left text-sm transition ${
                    isSelected
                    ? isAssigned
                        ? "bg-green-100 text-green-800"
                        : "bg-blue-100 text-blue-800"
                    : "text-gray-700 hover:bg-gray-100"
                }`}
                >
                {permission.name}
                </button>
            );
            })
        ) : (
            <p className="py-8 text-center text-sm text-gray-400">
            {search ? "No matching permissions" : "No permissions available"}
            </p>
        )}
        </div>
    </section>
    );

  return (
    <div className="flex h-full min-h-0 w-full flex-col ">
      <div className="mb-5 flex items-center gap-3">
        <button
          type="button"
          onClick={() => navigate("/access-management")}
          aria-label="Back to Access Management"
          className="rounded-lg p-2 text-brand-primary transition hover:bg-gray-200"
        >
          <ArrowLeft size={25} />
        </button>

        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-bold text-gray-900">
              Create Role
            </h1>
          </div>
        </div>
      </div>

      <form
        onSubmit={handleSubmit}
        className="min-h-0 flex-1 overflow-y-auto rounded-xl border border-gray-100 bg-white p-4 shadow-sm sm:p-6"
      >
        {/* Role Name and Description */}
        <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 sm:gap-6">
          <div className="min-w-0">
            <CustomTextField
              label="Role Name"
              name="roleName"
              value={roleName}
              onChange={(event) => {
                setRoleName(event.target.value);
                setErrors((previous) => ({
                  ...previous,
                  roleName: "",
                }));
              }}
              error={!!errors.roleName}
              helperText={errors.roleName}
            />
          </div>

          <div className="min-w-0">
            <CustomTextField
              label="Description"
              name="description"
              value={description}
              onChange={(event) =>
                setDescription(event.target.value)
              }
            />
          </div>
        </div>

        <div className="grid grid-cols-1 items-stretch gap-4 lg:grid-cols-[minmax(0,1fr)_64px_minmax(0,1fr)] lg:gap-5">
          {renderPermissionList({
            title: "Available Permissions",
            isAssigned: false,
            items: filteredAvailable,
            search: searchAvailable,
            setSearch: setSearchAvailable,
            selected: selectedAvailable,
            side: "available",
          })}

          <div className="flex flex-row items-center justify-center gap-3 lg:flex-col">
            <button
              type="button"
              onClick={moveRight}
              disabled={!selectedAvailable.length || loadingPermissions}
              aria-label="Assign selected permissions"
              className="flex h-11 w-14 items-center justify-center rounded-lg bg-blue-600 text-white shadow-sm transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-40"
            >
              <ChevronRight size={23} />
            </button>

            <button
              type="button"
              onClick={moveLeft}
              disabled={!selectedAssigned.length}
              aria-label="Remove selected permissions"
              className="flex h-11 w-14 items-center justify-center rounded-lg bg-blue-600 text-white shadow-sm transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-40"
            >
              <ChevronLeft size={23} />
            </button>

            <button
              type="button"
              onClick={moveAllRight}
              disabled={!availablePermissions.length || loadingPermissions}
              title="Assign all permissions"
              aria-label="Assign all permissions"
              className="flex h-11 w-14 items-center justify-center rounded-lg bg-blue-600 text-white shadow-sm transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-40"
            >
              <ChevronRight size={23} />
              <ChevronRight size={23} className="-ml-4" />
            </button>

            <button
              type="button"
              onClick={moveAllLeft}
              disabled={!assignedPermissions.length}
              title="Remove all permissions"
              aria-label="Remove all permissions"
              className="flex h-11 w-14 items-center justify-center rounded-lg bg-blue-600 text-white shadow-sm transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-40"
            >
              <ChevronLeft size={23} />
              <ChevronLeft size={23} className="-ml-4" />
            </button>
          </div>

          {renderPermissionList({
            title: "Assigned Permissions",
            isAssigned: true,
            items: filteredAssigned,
            search: searchAssigned,
            setSearch: setSearchAssigned,
            selected: selectedAssigned,
            side: "assigned",
          })}
        </div>

        <div className="mt-6 flex flex-col-reverse gap-3 pt-5 sm:flex-row sm:justify-end">
          <button
            type="button"
            onClick={() => navigate("/access-management")}
            disabled={saving}
            className="rounded-lg border border-gray-300 px-5 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50"
          >
            Cancel
          </button>

          <button
            type="submit"
            disabled={saving || loadingPermissions}
            className="inline-flex items-center justify-center gap-2 rounded-lg bg-brand-primary px-5 py-2.5 text-sm font-medium text-white hover:opacity-90 disabled:cursor-not-allowed disabled:opacity-60"
          >
            {saving ? (
              <>
                <LoaderCircle
                  size={17}
                  className="animate-spin"
                />
                Saving...
              </>
            ) : (
              <>
                {/* <Plus size={17} /> */}
                Save Role
              </>
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

export default CreateRole;
