import { run, css } from "uebersicht";

export const command = async dispatch => {
  const out = await run("/Users/aditya/.config/nvm/12.18.3/bin/node ./lib/background");
  dispatch({ type: "SET_BACKGROUND", data: out });
};

export const refreshFrequency = 5000;

export const updateState = (event, prevState) => {
  if (event.type === "SET_BACKGROUND") {
    return {
      bgUrl: event.data,
    };
  }
  return prevState;
};

export const render = ({ bgUrl }) => {
  return (
    <div className={background(bgUrl)}>
      <div className={desktopIcons} />
      </div>
    );
};

export const className = css({
  position: "absolute",
  top: 0,
  left: 0,
  width: "100%",
  height: "100%",
  backgroundColor: "#000",
})

const background = bgUrl => css({
  width: "100%",
  height: "100%",
  backgroundImage: `url('${bgUrl}')`,
  backgroundSize: "cover",
  borderRadius: "4px",
});

const desktopIcons = css({
  position: "absolute",
  right: "0px",
  top: "0px",
  height: "100%",
  width: "170px",
  borderRadius: "0px 4px 4px 0",
  backdropFilter: "blur(5px)",
});
