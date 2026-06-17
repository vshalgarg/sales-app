import { Bar } from "react-chartjs-2";

const CHART_HEIGHT = 450;
// Below this count, the chart fits the card width (no scroll).
const SCROLL_THRESHOLD = 10;
// Minimum horizontal space per category (grouped bars + label).
const WIDTH_PER_CATEGORY = 80;

export default function BarChart({ options, data }) {
  const labelCount = data?.labels?.length ?? 0;
  const needsScroll = labelCount > SCROLL_THRESHOLD;
  const chartMinWidth = needsScroll
    ? labelCount * WIDTH_PER_CATEGORY
    : undefined;

  return (
    <div
      style={{
        width: "100%",
        overflowX: needsScroll ? "auto" : "hidden",
      }}
    >
      <div
        style={{
          width: needsScroll ? chartMinWidth : "100%",
          minWidth: needsScroll ? chartMinWidth : undefined,
          height: CHART_HEIGHT,
        }}
      >
        <Bar options={options} data={data} />
      </div>
    </div>
  );
}
