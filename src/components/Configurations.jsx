import React, { useEffect, useState } from "react";
import AdminService from "../service/AdminService";
import { useConfig } from "../context/ConfigContext";
import { Button, Checkbox, FormControlLabel } from "@mui/material";
import { useSnackbar } from "../context/SnackbarContext";

function Configurations() {
  const [configurations, setConfigurations] = useState([]);
  const { config, refreshConfig } = useConfig();
  const { showSnackbar } = useSnackbar();

  const updateConfigurations = async () => {
    try {
      const retailConfiguration = configurations.find(
        (c) => c.key === "ENABLE_RETAIL",
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
        item.key === "ENABLE_RETAIL"
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
    (c) => c.key === "ENABLE_RETAIL",
  );

  return (
    <div>
      <div className="font-bold text-2xl mb-5 mt-2">Configurations</div>

      {retailConfiguration && (
        <>
          <FormControlLabel
            control={
              <Checkbox
                checked={retailConfiguration.value === "true"}
                onChange={(e) => handleRetailChange(e.target.checked)}
              />
            }
            label="Enable Retail"
          />
          <Button
            variant="contained"
            size="small"
            onClick={updateConfigurations}
          >
            Save
          </Button>
        </>
      )}
    </div>
  );
}

export default Configurations;
