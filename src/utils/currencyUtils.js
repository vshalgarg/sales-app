export const formatIndianCurrency = (amount) => {
  if (amount == null || isNaN(amount)) {
    return "-";
  }

  return new Intl.NumberFormat("en-IN", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount);
};