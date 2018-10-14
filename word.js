command: "~/.nvm/versions/node/v8.9.3/bin/node ~/dev/wordofday/showWord",

refreshFrequency: "1 hr",

render: output => {
  let lines = output.trim().split("\n");
  let heading = `<div class="heading-wrapper"><span class="heading">${lines[0].replace(/=/g, "").trim()}</span></div>`;

  let definition = lines.slice(1);
  definition[0] = definition[0].replace(/\\(\S+)\\/, `<span class="pronunciation">/$1/</span>`);
  definition[0] = definition[0].replace(/^(\S+)/, `<span class="word">$1</span>`);
  definition[0] = `<span class="first-line">${definition[0]}</span>`;
  definition = definition.join("<br />");

  return heading + `<div class="definition">${definition}</div>`;
},

style: `
  position: absolute;
  bottom: 10px;
  left: 10px;
  color: #888573;
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata

  .heading
    font-family: "Gill Sans"
    text-transform: uppercase
    color: #444
    border-bottom: 1px solid rgba(#444, 0.5)

  .word
    display: inline-block
    font-weight: bold
    margin-bottom: 1em

  .pronunciation
    color: #444
    font-style: italic

  .definition
    display: inline-block
    margin-left: 10px
    margin-top: 1em
    line-height: 1.5em

    .first-line
      margin-left: -10px
`
