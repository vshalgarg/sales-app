import { Bar } from "react-chartjs-2";

const CHART_HEIGHT = 600;
const SCROLL_THRESHOLD = 10;
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
          position: "relative",
          width: "100%",
          minWidth: chartMinWidth,
          height: CHART_HEIGHT,
        }}
      >
        <Bar options={options} data={data} />
      </div>
    </div>
  );
}
