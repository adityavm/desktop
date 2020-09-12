import { css, run } from "uebersicht";

const toggle = currentStatus => async () => {
  let output;
  if (currentStatus === "1") {
    output = await run("defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean false");
  } else {
    output = await run("defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean true");
  }
}

export const command = dispatch => {
  run("defaults -currentHost read ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb")
    .then(output => {
      dispatch({ type: "SET_OUTPUT", data: output });
    })
}

export const refreshFrequency = 5000;

export const updateState = (action, prevState) => {
  if (action.type === "SET_OUTPUT") {
    return action.data.trim();
  }
  return (prevState || {});
}

export const render = output => (
  <div
    className={`${box} ${output === "1" ? isOn : isOff}`}
    onClick={toggle(output)}
  >
    ☾
  </div>
);

export const className = `
  bottom: 10px;
  left: 10px;
`;

export const box = css({
  font: `12px -apple-system, Osaka-Mono, Hack, Inconsolata;`,
  height: `40px`,
  lineHeight: `26px`,
  textAlign: `center`,
  display: `flex`,
  alignItems: `center`,
  justifyContent: `center`,
  backgroundColor: `#232021`,
  borderRadius: `5px`,
  padding: `0 10px`,
  cursor: "pointer",
  transition: "color 0.2s",
});

const isOn = css({
  color: "#cc8899",
  backgroundColor: "rgba(35, 35, 35, 0.8)",
  "&:hover": {
    color: "#ec3f1d",
  },
});

const isOff = css({
  color: "#666",
  "&:hover": {
    color: "#b5c625",
  },
})