import { Line } from "react-chartjs-2";

const CHART_HEIGHT = 300;
const SCROLL_THRESHOLD = 12;
const WIDTH_PER_LABEL = 80;

export default function LineChart({ options, data }) {
  const labelCount = data?.labels?.length ?? 0;
  const needsScroll = labelCount > SCROLL_THRESHOLD;
  const chartMinWidth = needsScroll ? labelCount * WIDTH_PER_LABEL : undefined;

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
        <Line options={options} data={data} />
      </div>
    </div>
  );
}