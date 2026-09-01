import React, { useEffect, useState } from "react";
import AdminService from "@/services/AdminService";
import { useConfig } from "@/contexts/ConfigContext";
import { Button, Checkbox, FormControlLabel } from "@mui/material";
import { useSnackbar } from "@/contexts/SnackbarContext";
import AppButton from "@/components/AppButton";

function Configurations() {
  const [configurations, setConfigurations] = useState([]);
  const { config, refreshConfig } = useConfig();
  const { showSnackbar } = useSnackbar();

  const updateConfigurations = async () => {
    try {
      const retailConfiguration = configurations.find(
        (c) => c.key === "RETAIL_FEATURE",
      );

      const retailConfigurationId = retailConfiguration.id;
      const payload = {
        value: retailConfiguration.value,
      };

      const result = await AdminService.updateConfigurations(
        retailConfigurationId,
        payload,
      );
      showSnackbar(
        result.message || "configuration updated successfully",
        "success",
      );

      await refreshConfig();
    } catch (error) {
      showSnackbar(error.message || "something went wrong!", "error");
    }
  };

  const handleRetailChange = (checked) => {
    setConfigurations((prev) =>
      prev.map((item) =>
        item.key === "RETAIL_FEATURE"
          ? {
              ...item,
              value: String(checked),
            }
          : item,
      ),
    );
  };

  useEffect(() => {
    refreshConfig();
  }, []);

  useEffect(() => {
    if (config) {
      setConfigurations(config);
    }
  }, [config]);

  const retailConfiguration = configurations?.find(
    (c) => c.key === "RETAIL_FEATURE",
  );

  return (
  <div className="h-full flex flex-col">
    {/* Header */}
    <div className="mb-6">
      <h1 className="text-2xl font-bold">Configurations</h1>
      <p className="text-sm text-gray-500 mt-1">
        Manage application features and settings.
      </p>
    </div>

    {/* Configurations */}
    <div className="flex-1 overflow-y-auto space-y-4 pb-24">
      {retailConfiguration && (
        <div className="bg-white border border-gray-200 rounded-lg shadow-sm p-5">
          <div className="flex items-start justify-between">
            <div>
              <h3 className="font-semibold text-gray-800">
                Enable Retail Module
              </h3>
              <p className="text-sm text-gray-500 mt-1">
                Allows users to access Retail Entry and Retail reports.
              </p>
            </div>

            <FormControlLabel
              control={
                <Checkbox
                  className="!text-brand-primary"
                  checked={retailConfiguration.value === "true"}
                  onChange={(e) =>
                    handleRetailChange(e.target.checked)
                  }
                />
              }
            />
          </div>
        </div>
      )}
    </div>

    {/* Sticky Footer */}
    <div className="sticky bottom-0 bg-white border-t border-gray-200 py-3 px-4 flex justify-end">
      <AppButton
        variant="primary"
        disabled={configurations.length == 0}
        onClick={updateConfigurations}
      >
        Save Changes
      </AppButton>
    </div>
  </div>
);
}

export default Configurations;
