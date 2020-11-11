import { css, run } from "uebersicht";

export const refreshFrequency = false;

export const command = dispatch => {
  (async () => {
    const out = await run("tail -n 1 ./lib/message");
    dispatch({ type: "SET_OUTPUT", data: out, hidden: false });

    setTimeout(() => {
      dispatch({ type: "SET_OUTPUT", data: out, hidden: true });
    }, 5000);
  })();
};

export const updateState = (event, prevState) => {
  if (event.type === "SET_OUTPUT") {
    return {
      output: event.data,
      hidden: event.hidden,
    };
  }
  return prevState;
}

export const render = ({ output, hidden }) => {
  return (
    <div className={`${message} ${hidden ? isHidden : null}`}>{output}</div>
  );
};

export const className = css({
  bottom: "10px",
  right: "260px",
});

export const message = css({
  height: "40px",
  backgroundColor: "#ee6aa0ff",
  backdropFilter: "blur(5px)",
  color: "#fff",
  borderRadius: "4px",
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
  padding: "0 10px",
  font: "12px 'Dank Mono', monospace",
  opacity: 1,
  transition: "opacity 0.4s",
});

export const isHidden = css({
  opacity: 0,
})