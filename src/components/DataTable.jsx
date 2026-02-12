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
} from "@mui/material";

import MoreVertIcon from "@mui/icons-material/MoreVert";
import VisibilityIcon from "@mui/icons-material/Visibility";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";

const DataTable = ({
  columns,
  data,
  loading = false,
  onView,
  onEdit,
  onDelete,
  actions = true,
  page,
  totalCount,
  rowsPerPage = 10,
  onPageChange,
  disablePagination = false,
  emptyMessage = "No records found",
}) => {
  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedRow, setSelectedRow] = useState(null);

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

  const showPagination = !disablePagination && totalCount > 0 && totalCount > rowsPerPage;

  return (
    <Paper elevation={3} sx={{ borderRadius: 2, display: "flex", flexDirection: "column", height: "100%" }}>
      <TableContainer
        sx={{
          flex: 1,
          minHeight: 0,
          overflowX: "hidden", 
          overflowY: "auto",
        }}
      >
        <Table stickyHeader size="small"
          sx={{
            tableLayout: "fixed",
            width: "100%",
          }}>
          {/* TABLE HEAD */}
          <TableHead>
            <TableRow sx={
              {
                backgroundColor: "#e0e0e0",
                height: 48
              }
            }>
              {columns.map((col) => (
                <TableCell
                  key={col.key}
                  sx={{
                    fontWeight: 600, width: col.width,
                    //  backgroundColor: '#e0e0e0',
                    bgcolor: 'inherit',

                  }}
                >
                  {col.label}
                </TableCell>
              ))}
              {actions && <TableCell sx={{ width: "80px", backgroundColor: '#e0e0e0', fontWeight: 600 }}>Actions</TableCell>}
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
                        maxWidth: 0,
                        whiteSpace: "normal",
                        wordBreak: "break-word",
                        overflowWrap: "anywhere",
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
            ) : (
              <TableRow>
                <TableCell
                  colSpan={columns.length + (actions ? 1 : 0)}
                  align="center"
                  sx={{ py: 8 }}
                >
                  <Typography color="text.secondary">{emptyMessage}</Typography>
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* MUI Pagination – only show if there's more than one page worth of data */}
      {showPagination && (
        <TablePagination
          component="div"
          count={totalCount}
          page={page - 1} // 0-based index
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
            borderTop: "1px solid",
            borderColor: "divider",
            ".MuiTablePagination-selectLabel, .MuiTablePagination-displayedRows": {
              fontSize: "0.875rem",
            },
          }}
        />
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