// src/components/ExpandableDataTable.jsx
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
  Collapse,
  Box,
  Typography,
  TablePagination,
  Tooltip,
  Menu,
  MenuItem,
  CircularProgress,
} from "@mui/material";
import KeyboardArrowDownIcon from "@mui/icons-material/KeyboardArrowDown";
import KeyboardArrowUpIcon from "@mui/icons-material/KeyboardArrowUp";
import MoreVertIcon from "@mui/icons-material/MoreVert";
import useResponsive from "../customHooks/useResponsive";
import { BRAND_COLORS } from "../theme/brandColors";

const headerCellSx = {
  fontWeight: 600,
  bgcolor: "#f3f0ff",
  color: BRAND_COLORS.primary,
  whiteSpace: "nowrap",
};

const nestedHeaderCellSx = {
  ...headerCellSx,
  bgcolor: "#f7f5ff",
};

const inlineActionButtonSx = (isDelete = false) => ({
  border: `1px solid ${BRAND_COLORS.surfaceBorder}`,
  borderRadius: "8px",
  width: 34,
  height: 34,
  bgcolor: isDelete ? "#fef2f2" : "#ffffff",
  "&:hover": {
    bgcolor: isDelete ? "#fee2e2" : "#f8fafc",
  },
});

/* ─── Sub-table row with inline edit/delete actions ─── */
const SubTableRow = ({ row, index, columns, actionItems = [], isMobile }) => (
  <TableRow hover>
    {columns.map((col) => (
      <TableCell
        key={col.key}
        sx={{
          px: isMobile ? 1 : 2,
          whiteSpace: "nowrap",
          overflow: "hidden",
          textOverflow: "ellipsis",
        }}
      >
        {col.render
          ? col.render(row, index)
          : row[col.key] == null || row[col.key] === ""
            ? "-"
            : row[col.key]}
      </TableCell>
    ))}

    {actionItems.length > 0 && (
      <TableCell sx={{ px: 1 }}>
        <Box sx={{ display: "flex", gap: 0.75, justifyContent: "flex-start" }}>
          {actionItems.map((item, i) => {
            const isDelete = item.label === "Delete";
            const Icon = item.icon;

            return (
              <IconButton
                key={i}
                size="small"
                onClick={() => item.onClick(row)}
                aria-label={item.label}
                sx={inlineActionButtonSx(isDelete)}
              >
                {Icon && (
                  <Icon
                    fontSize="small"
                    sx={{ color: isDelete ? "#dc2626" : BRAND_COLORS.primary }}
                  />
                )}
              </IconButton>
            );
          })}
        </Box>
      </TableCell>
    )}
  </TableRow>
);

/* ─── Sub-table rendered inside accordion ─── */
const SubTable = ({ columns = [], rows = [], actionItems = [], isMobile }) => (
  <Table size="small">
    <TableHead>
      <TableRow>
        {columns.map((col) => (
          <TableCell
            key={col.key}
            sx={{ ...nestedHeaderCellSx, width: col.width }}
          >
            {col.label}
          </TableCell>
        ))}
        {actionItems.length > 0 && (
          <TableCell sx={{ ...nestedHeaderCellSx, width: 96 }}>
            Actions
          </TableCell>
        )}
      </TableRow>
    </TableHead>
    <TableBody>
      {rows.map((row, i) => (
        <SubTableRow
          key={row.id ?? i}
          row={row}
          index={i}
          columns={columns}
          actionItems={actionItems}
          isMobile={isMobile}
        />
      ))}
    </TableBody>
  </Table>
);

/* ─── Single expandable row ─── */
const ExpandableRow = ({
  row = {},
  index,
  columns = [],
  expandedColumns = [],
  open,        
  onToggle,
  getExpandedRows,
  expandedActionItems = [],
  expandedLabel,
  totalCols,
  actions,
  actionsWidth,
  actionItems = [],
  isMobile,
}) => {
  const [anchorEl, setAnchorEl] = useState(null);

  const subRows = getExpandedRows ? (getExpandedRows(row) ?? []) : [];
  const count = subRows.length;

  return (
    <>
      <TableRow
        hover
        sx={{ "& > *": { borderBottom: open ? "unset" : undefined } }}
      >
        {/* Expand toggle */}
        <TableCell sx={{ width: 48, px: 1 }}>
          <Tooltip title={open ? "Collapse" : `Expand (${count})`}>
            <span>
              <IconButton
                size="small"
                onClick={onToggle}
                disabled={count === 0}
              >
                {open ? <KeyboardArrowUpIcon /> : <KeyboardArrowDownIcon />}
              </IconButton>
            </span>
          </Tooltip>
        </TableCell>

        {/* Data columns */}
        {columns.map((col) => (
          <TableCell
            key={col.key}
            sx={{
              whiteSpace: "nowrap",
              overflow: "hidden",
              textOverflow: "ellipsis",
              px: isMobile ? 1 : 2,
              width: col.width,
            }}
          >
            {col.render
              ? col.render(row, index)
              : row[col.key] == null || row[col.key] === ""
                ? "-"
                : row[col.key]}
          </TableCell>
        ))}

        {/* Actions menu — fully caller-controlled */}
        {actions && (
          <TableCell sx={{ width: actionsWidth, px: 1 }}>
            <IconButton
              size="small"
              onClick={(e) => setAnchorEl(e.currentTarget)}
            >
              <MoreVertIcon />
            </IconButton>
            <Menu
              anchorEl={anchorEl}
              open={Boolean(anchorEl)}
              onClose={() => setAnchorEl(null)}
              anchorOrigin={{ vertical: "bottom", horizontal: "right" }}
              transformOrigin={{ vertical: "top", horizontal: "right" }}
            >
              {actionItems.map((item, i) => (
                <MenuItem
                  key={i}
                  onClick={() => {
                    item.onClick(row);
                    setAnchorEl(null);
                  }}
                  sx={item.sx ?? {}}
                >
                  {item.icon && <item.icon fontSize="small" sx={{ mr: 1 }} />}
                  {item.label}
                </MenuItem>
              ))}
            </Menu>
          </TableCell>
        )}
      </TableRow>

      {/* Accordion row */}
      <TableRow>
        <TableCell
          colSpan={totalCols}
          sx={{ py: 0, border: 0, bgcolor: "#f8f9ff" }}
        >
          <Collapse in={open} timeout="auto" unmountOnExit>
            <Box
              sx={{
                mx: { xs: 1, md: 4 },
                my: 1.5,
                border: `1px solid ${BRAND_COLORS.surfaceBorder}`,
                borderRadius: 2,
                overflow: "hidden",
                bgcolor: "#fff",
              }}
            >
              {expandedLabel && (
                <Typography
                  variant="subtitle2"
                  sx={{ mb: 1, color: "text.secondary" }}
                >
                  {typeof expandedLabel === "function"
                    ? expandedLabel(row)
                    : expandedLabel}
                </Typography>
              )}
              <SubTable
                columns={expandedColumns}
                actionItems={expandedActionItems}
                rows={subRows}
                isMobile={isMobile}
              />
            </Box>
          </Collapse>
        </TableCell>
      </TableRow>
    </>
  );
};

/* ─── Main component ─── */
const ExpandableDataTable = ({
  columns,
  data,
  loading = false,
  actions = true,
  actionsWidth = "60px",
  actionItems = [],
  page,
  totalCount,
  rowsPerPage = 10,
  onPageChange,
  disablePagination = false,
  emptyMessage = "No records found",
  expandedColumns = [],
  expandedActionItems = [],
  getExpandedRows,
  expandedLabel,
  tableLayout = "fixed",
}) => {
  const { isMobile } = useResponsive();
  const [openRowIndex, setOpenRowIndex] = useState(null);

  const safeData = data ?? [];
  const safeCols = columns ?? [];

  const showPagination = !disablePagination && (totalCount ?? 0) > 0;
  const totalCols = safeCols.length + 1 + (actions ? 1 : 0);

  return (
    <Paper
      elevation={0}
      sx={{
        borderRadius: 2,
        border: "none",
        display: "flex",
        flexDirection: "column",
        height: "100%",
        bgcolor: "#fff",
      }}
    >
      <TableContainer
        sx={{
          flex: 1,
          minHeight: 0,
          overflowX: "auto",
          overflowY: "auto",
          display: "flex",
          flexDirection: "column",
        }}
      >
        <Table
          stickyHeader
          size="small"
          sx={{
            tableLayout: isMobile ? "auto" : tableLayout,
            width: "100%",
            flexShrink: 0,
          }}
        >
          <TableHead>
            <TableRow sx={{ height: 48 }}>
              <TableCell sx={{ ...headerCellSx, width: 48 }} />

              {safeCols.map((col) => (
                <TableCell
                  key={col.key}
                  sx={{
                    ...headerCellSx,
                    width: col.width,
                    px: isMobile ? 1 : 2,
                  }}
                >
                  {col.label}
                </TableCell>
              ))}

              {actions && (
                <TableCell
                  sx={{
                    ...headerCellSx,
                    width: actionsWidth,
                    px: isMobile ? 1 : 2,
                  }}
                >
                  Actions
                </TableCell>
              )}
            </TableRow>
          </TableHead>

          {loading && (
            <TableBody>
              <TableRow>
                <TableCell colSpan={totalCols} align="center" sx={{ py: 8, border: 0 }}>
                  <CircularProgress />
                </TableCell>
              </TableRow>
            </TableBody>
          )}

          {!loading && safeData.length > 0 && (
            <TableBody>
              {safeData.map((row, i) => (
                <ExpandableRow
                  key={i}
                  row={row}
                  index={i}
                  open={openRowIndex === i}
                  onToggle={() => setOpenRowIndex(openRowIndex === i ? null : i)}
                  columns={safeCols}
                  expandedColumns={expandedColumns}
                  expandedActionItems={expandedActionItems}
                  getExpandedRows={getExpandedRows}
                  expandedLabel={expandedLabel}
                  totalCols={totalCols}
                  actions={actions}
                  actionsWidth={actionsWidth}
                  actionItems={actionItems}
                  isMobile={isMobile}
                />
              ))}
            </TableBody>
          )}
        </Table>

        {!loading && safeData.length === 0 && (
          <Box
            sx={{
              flex: 1,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              minHeight: 180,
              px: 2,
            }}
          >
            <Typography color="text.secondary" align="center">
              {emptyMessage}
            </Typography>
          </Box>
        )}
      </TableContainer>

      {showPagination && (
        <TablePagination
          component="div"
          count={totalCount}
          page={(page ?? 1) - 1}
          rowsPerPage={rowsPerPage}
          onPageChange={(_, newPage) => onPageChange?.(newPage + 1)}
          rowsPerPageOptions={[]}
          showFirstButton
          showLastButton
          labelDisplayedRows={({ from, to, count }) =>
            `${from}–${to} of ${count !== -1 ? count : `more than ${to}`}`
          }
          sx={{
            borderTop: "1px solid",
            borderColor: "divider",
            ".MuiTablePagination-displayedRows": { fontSize: "0.875rem" },
          }}
        />
      )}
    </Paper>
  );
};

export default ExpandableDataTable;
