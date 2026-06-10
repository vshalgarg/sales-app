import { Pie } from "react-chartjs-2";

export default function PieChart({ options, data }) {
  return (
    <div style={{ width: "100%", height: "450px" }}>
      <Pie options={options} data={data} />
    </div>
  );
}