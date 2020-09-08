import { run, css } from "uebersicht";

const options = {
  refresh: 2500,
  cutOff: 60,
};

const outputFmt = ({ app, title }) => {
  if (!app && !title) return ["", ""];

  // Make window title useful
  title = title.replace(new RegExp(`\s?-?.?${app}.?-?\s?`, "ig"), ""); // remove app name
  title = title.length > options.cutOff
    ? "..." + title.substr(title.length - options.cutOff, title.length)
    : title;

  // Get window name from app
  if (app === "Electron") {
    const titleRegexp = /(\w+)(\s-\s)/g;
    const windowName = title.match(titleRegexp);
    if (windowName) {
      app = windowName[0].replace(/\s-\s/, "");
      title = title.replace(titleRegexp, "");
    }
  }

  return [app, title];
};

const getGreeting = () => {
  const time = (new Date()).getHours();
  let greet;

  if (time >= 0 && time < 6) {
    greet = "You should sleep"
  }

  if (time >= 6 && time < 12) {
    greet = "Good Morning";
  }

  if (time >= 12 && time < 17) {
    greet = "Good Afternoon";
  }

  if (time >= 17 && time < 24) {
    greet = "Good Evening"
  }

  return `${greet}, Aditya!`;
};

export const command = async dispatch => {
  let windowJSON;
  try {
    const windows = await run("/usr/local/bin/yabai -m query --windows --window");
    windowJSON = JSON.parse(windows);
  } catch (e) {
    windowJSON = {};
  }
  if (windowJSON.display !== 2) {
    winddowJSON = {};
  }

  const spaces = await run("/usr/local/bin/yabai -m query --spaces");

  dispatch({
    type: "SET_STATE",
    app: windowJSON.app,
    title: windowJSON.title,
    spaces,
  });
}

export const updateState = (event, prevState) => {
  if (event.type === "SET_STATE") {
    return {
      app: event.app,
      title: event.title,
      spaces: event.spaces,
    };
  }
  return prevState;
};

export const render = ({ app, title, spaces }) => {
  const [fmtApp, fmtTitle] = outputFmt({ app, title });
  const isEmpty = !fmtApp && !fmtTitle;

  if (!spaces || typeof spaces === "undefined") return null;

  const spacesArr = JSON.parse(spaces).filter(spc => spc.display === 2);

  return (
    <div className={parent}>
      <div className={spacesContainer}>
        {spacesArr.map((spc, i) => (
          <span key={spc.id} className={`${space} ${spc.focused ? activeSpace : null}`}>
            {i !== 0 && (
              <span className={spaceDivider}>&nbsp;</span>
            )}
            <span className={`${spaceLabel} ${spc.focused ? spaceActiveLabel : ``}`}>
             {spc.label || spc.index}
            </span>
          </span>
        ))}
      </div>
      <div className={`${contentStyles} ${isEmpty ? emptyStyles : ``}`}>
        {!isEmpty
          ? (
            <div>
              <span className={windowStyles}>{fmtApp}</span>
              {fmtTitle && (
                <span className={titleStyles}>
                  <span className={dividerStyles}>/</span>
                  {fmtTitle}
                </span>
              )}
            </div>
          )
          : (
            getGreeting()
          )}
        </div>
      </div>
    );
};

export const className = `
  position: absolute;
  bottom: 10px;
  left: 60px;
  height: 40px;
`;

const parent = css({
  display: "flex",
});

const spacesContainer = css({
  font: `12px "Dank Mono", -apple-system, Osaka-Mono, Hack, Inconsolata`,
  display: "flex",
  backgroundColor: "#222",
  backdropFilter: "blur(10px)",
  borderRadius: "4px",
  overflow: "hidden",
});

const space = css({
  display: "inline-flex",
  alignItems: "center",
  height: "40px",
  transition: "0.3s",
  position: "relative",
  ":first-child": {
    paddingLeft: "10px",
    borderRadius: "4px 0 0 4px",
  },
  ":last-child": {
    paddingRight: "10px",
    borderRadius: "0 4px 4px 0",
  },
  "&:before": {
    position: "absolute",
    top: "20px",
    left: "18px",
    width: "30px",
    height: "100%",
    transform: "translate(-50%, -50%) skew(-26deg)",
    zIndex: -1,
    transition: "color 0.3s, background-color 0.3s",
  },
});

const activeSpace = css({
  "&:before": {
    content: '""',
    // backgroundColor: "#ee6aa0",
    backgroundColor: "#2f2f2f",
    color: "#ee6aa0",
  },
});

const spaceDivider = css({
  paddding: "0 5px",
});

const spaceLabel = css({
  color: "rgba(160, 160, 160, 0.5)",
  backgroundColor: "transparent",
  display: "inline-flex",
  justifyContent: "center",
  alignItems: "center",
  lineHeight: "16px",
  width: "20px",
  height: "20px",
  borderRadius: "50%",
  transition: "0.3s",
});

const spaceActiveLabel = css({
  color: "#999",
  fontWeight: 600,
});

const windowStyles = css({
  color: "rgba(#aaa, 0.75)",
  opacity: "0.75",
  textTransform: "uppercase",
  color: "#aaa",
});

const titleStyles = css({});

const contentStyles = css({
  font: `12px "Dank Mono", -apple-system, Osaka-Mono, Hack, Inconsolata`,
  color: "#aaa",
  zIndex: 2,
  height: "26px",
  lineHeight: "26px",
  whiteSpace: "nowrap",
  opacity: 1,
  transition: "opacity 0.2s, background-color 0.2s, color 0.2s",
  backgroundColor: "#232021",
  height: "40px",
  borderRadius: "5px",
  display: "flex",
  alignItems: "center",
  justifyContent: "flex-start",
  padding: "0px 20px",
  marginLeft: "15px",
});

const dividerStyles = css({
  color: "rgba(170, 170, 170, 0.5)",
  opacity: 0.25,
  margin: "0 5px",
});

const emptyStyles = css({
  backdropFilter: "blur(10px)",
  backgroundColor: "rgba(204, 204, 204, 0.5)",
  color: "#fff",
});