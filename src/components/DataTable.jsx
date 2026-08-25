// src/components/DataTable.jsx
import { useState } from "react";
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton,
  Menu,
  MenuItem,
  CircularProgress,
  Typography,
  TablePagination,
  Box,
} from "@mui/material";

import MoreVertIcon from "@mui/icons-material/MoreVert";
import VisibilityIcon from "@mui/icons-material/Visibility";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import ContentCopyIcon from "@mui/icons-material/ContentCopy";
import useResponsive from "../hooks/useResponsive";

const DataTable = ({
  columns,
  data,
  loading = false,
  onView,
  onEdit,
  onDelete,
  totalAmount,
  onCopy,
  actions = true,
  page,
  totalCount,
  rowsPerPage = 10,
  onPageChange,
  disablePagination = false,
  emptyMessage = "No records found",
  headerRowSx,
  headerCellSx,
  actionsHeaderSx,
  autoHeight = false,
}) => {
  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedRow, setSelectedRow] = useState(null);
  const { isMobile } = useResponsive();

  const handleOpenMenu = (event, row) => {
    setAnchorEl(event.currentTarget);
    setSelectedRow(row);
  };

  const handleCloseMenu = () => {
    setAnchorEl(null);
    setSelectedRow(null);
  };

  const handleChangePage = (event, newPage) => {
    // MUI TablePagination uses 0-based index, we convert to 1-based for our logic
    onPageChange?.(newPage + 1);
  };

  const showPagination = !disablePagination && totalCount > 0;

  return (
    <Paper
      elevation={3}
      sx={{
        borderRadius: 2,
        display: "flex",
        flexDirection: "column",
        height: autoHeight ? "auto" : "100%",
      }}
    >
      <TableContainer
        sx={{
          flex: autoHeight ? "none" : 1,
          minHeight: autoHeight ? "auto" : 0,
          overflowX: "auto",
          overflowY: autoHeight ? "visible" : "auto",
          display: "flex",
          flexDirection: "column",
        }}
      >
        <Table
          stickyHeader={!autoHeight}
          size="small"
          sx={{
            tableLayout: isMobile ? "auto" : "fixed",
            width: "100%",
            flexShrink: 0,
          }}
        >
          {/* TABLE HEAD */}
          <TableHead>
            <TableRow
              sx={{
                backgroundColor: "#e0e0e0",
                height: 48,
                ...headerRowSx,
              }}
            >
              {columns.map((col) => (
                <TableCell
                  key={col.key}
                  sx={{
                    fontWeight: 600, width: col.width,
                    //  backgroundColor: '#e0e0e0',
                    bgcolor: 'inherit',
                    px: isMobile ? 1 : 2,
                    ...headerCellSx,
                  }}
                >
                  {col.label}
                </TableCell>
              ))}
              {actions && (
                <TableCell
                  sx={{
                    px: isMobile ? 1 : 2,
                    width: isMobile ? "40px" : "6%",
                    minWidth: isMobile ? "40px" : "80px",
                    backgroundColor: "#e0e0e0",
                    fontWeight: 600,
                    ...headerCellSx,
                    ...actionsHeaderSx,
                  }}
                >
                  Actions
                </TableCell>
              )}
            </TableRow>
          </TableHead>

          {/* TABLE BODY */}
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell
                  colSpan={columns.length + (actions ? 1 : 0)}
                  align="center"
                  sx={{ py: 8 }}
                >
                  <CircularProgress />
                </TableCell>
              </TableRow>
            ) : data.length > 0 ? (
              data.map((row, index) => (
                <TableRow key={row.id || row.code || index} hover>
                  {columns.map((col) => (
                    <TableCell
                      key={col.key}
                      sx={{
                        whiteSpace: "nowrap",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        px: isMobile ? 1 : 2,
                      }}
                    >
                      {col.render
                        ? col.render(row, index)
                        : (row[col.key] == null || row[col.key] === "")
                          ? "-"
                          : row[col.key]
                      }
                    </TableCell>
                  ))}
                  {actions && (
                    <TableCell>
                      <IconButton size="small" onClick={(e) => handleOpenMenu(e, row)}>
                        <MoreVertIcon />
                      </IconButton>
                    </TableCell>
                  )}
                </TableRow>
              ))
            ) : null}
          </TableBody>
        </Table>

        {!loading && data.length === 0 && (
          <Box
            sx={{
              flex: autoHeight ? "none" : 1,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              minHeight: autoHeight ? 220 : 180,
              px: 2,
            }}
          >
            <Typography color="text.secondary" align="center">
              {emptyMessage}
            </Typography>
          </Box>
        )}
      </TableContainer>

      {/* MUI Pagination – only show if there's more than one page worth of data */}
      {showPagination && (
        <div style={{ display: "flex", alignItems: "center", borderTop: "1px solid", borderColor: "divider" }}>

        {/* Left: total amount — only renders if passed */}
        {totalAmount != null && (
          <div style={{ paddingLeft: "16px", fontSize: "0.875rem", fontWeight: 600, whiteSpace: "nowrap" }}>
          TotalAmount: ₹{totalAmount}
          </div>
        )}
        <TablePagination
          component="div"
          count={totalCount}
          page={page - 1}
          rowsPerPage={rowsPerPage}
          onPageChange={(event, newPage) => {
            onPageChange?.(newPage + 1);
          }}
          onRowsPerPageChange={(event) => {
            onRowsPerPageChange?.(parseInt(event.target.value, 10));
          }}
          rowsPerPageOptions={[]}
          showFirstButton
          showLastButton
          labelRowsPerPage="Rows per page:"
          labelDisplayedRows={({ from, to, count }) =>
            `${from}–${to} of ${count !== -1 ? count : `more than ${to}`}`
          }
          sx={{
            marginLeft: "auto",
            borderTop: "1px solid",
            borderColor: "divider",
            ".MuiTablePagination-selectLabel, .MuiTablePagination-displayedRows": {
              fontSize: "0.875rem",
            },
          }}
        />
        </div>
      )}

      {/* Action Menu */}
      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={handleCloseMenu}
        anchorOrigin={{ vertical: "bottom", horizontal: "right" }}
        transformOrigin={{ vertical: "top", horizontal: "right" }}
      >
        {onView && (
          <MenuItem
            onClick={() => {
              onView(selectedRow);
              handleCloseMenu();
            }}
          >
            <VisibilityIcon fontSize="small" sx={{ mr: 1 }} />
            View Details
          </MenuItem>
        )}

        {onEdit && (
          <MenuItem
            onClick={() => {
              onEdit(selectedRow);
              handleCloseMenu();
            }}
          >
            <EditIcon fontSize="small" sx={{ mr: 1 }} />
            Edit
          </MenuItem>
        )}

        {onCopy && (
          <MenuItem
            onClick={() => {
              onCopy(selectedRow);
              handleCloseMenu();
            }}
          >
            <ContentCopyIcon fontSize="small" sx={{ mr: 1 }} />
            Copy Details
          </MenuItem>
        )}

        {onDelete && (
          <MenuItem
            onClick={() => {
              onDelete(selectedRow);
              handleCloseMenu();
            }}
            sx={{ color: "error.main" }}
          >
            <DeleteIcon fontSize="small" sx={{ mr: 1 }} />
            Delete
          </MenuItem>
        )}
      </Menu>
    </Paper>
  );
};

export default DataTable;