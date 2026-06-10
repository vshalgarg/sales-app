import { Line } from "react-chartjs-2";

export default function LineChart({ options, data }) {
  return (
    <div style={{ width: "100%", height: "100%" }}>
      <Line options={options} data={data} />
    </div>
  );
}