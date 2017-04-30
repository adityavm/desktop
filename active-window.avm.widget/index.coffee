# public

options =
  refresh: 500
  cutOff: 60

# internal

outputFmt = (output) ->
  split = output.match /([^,]+),(.+)/
  win = split[1].trim()
  title = split[2].trim()
  titleSubs = if title.length > options.cutOff then "..." + title.substr title.length - options.cutOff, title.length else title

  titleSubs = titleSubs.replace(/🔊/g, "<div class='icon icon-speaker'><div class='lines'></div></div>")

  windowSpan = "<span class='window'>#{win}</span>"
  titleSpan = "<span class='title'>#{titleSubs}</span>"

  out = "#{windowSpan}"
  if titleSubs
    out += " <span class='divider'>/</span> #{titleSpan}"

  return [win, title, titleSubs, out]

# widget

command: "osascript active-window.avm.widget/lib/window_title.scpt"

refreshInterval: options.refresh,

render: (output) ->
  "<div class='content'></div>"

update: (output, domEl) ->
  [win, title, titleSubs, html] = outputFmt output

  el = $(domEl).find(".content")

  if (win == "Finder" and title == "")
    el.addClass("empty").html("")
    return

  el.removeClass("empty")

  domText = el.text()
  newText = "#{win} / #{titleSubs}"
  oldWin = el.find(".window").text()

  # animate if different window + title is different
  if win != oldWin
    if domText != newText
      el.addClass("transit")

  el.html(html)

  if el.hasClass("transit") then setTimeout (() -> el.removeClass("transit")), 200

style: """
  .content
    position: absolute
    top: 0
    left: 10px
    font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
    color: #555
    z-index: 2
    height: 26px
    background-color: #141414
    line-height: 26px
    min-width: 200px
    white-space: nowrap
    opacity: 1
    transition: opacity 0.2s

  .content > span
    opacity: 1
    transition: opacity 0.2s

  .transit > span
    opacity: 0

  .empty
    opacity: 0

  .icon
    width: 10px
    height: 10px
    background-color: currentColor
    position: relative
    top: 8px
    display: inline-block
    transform: scale(0.45)

    &:after
      content: ""
      width: 0px
      height: 0px
      border-width: 10px
      border-style: solid
      border-color: transparent currentColor transparent transparent
      position: absolute
      left: -8px
      top: -5px
      display: inline-block

    .lines
      border-left: 1px solid currentColor
      position: relative
      left: 15px
      height: 10px
      display: inline-block

      &:after
        content: ""
        border-left: 1px solid currentColor
        position: relative
        left: 4px
        top: -4px
        height: 15px
        display: inline-block

  span.window
    color: #888573
    min-width: 200px
"""
