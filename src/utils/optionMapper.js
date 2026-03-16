export const mapToOption = (data, idKey, labelKey) => {
  if (!Array.isArray(data)) return [];

    return data.map((item) => ({
    id: item[idKey],
    label: item.city
      ? `${item[labelKey]} - ${item.city}`
      : item[labelKey],
  }));
};