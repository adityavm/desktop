options =
  refresh: 1000
  cutOff: 60

command: "osascript active-window.avm.widget/lib/window_title.scpt"

refreshInterval: 1000,

render: (output) ->
  split = output.match /(.+),(.+)/
  win = split[1].trim()
  title = split[2].trim()
  titleSubs = if title.length > options.cutOff then "&hellip;" + title.substr title.length - options.cutOff, title.length else title

  # let greeter take over if on desktop
  if win == "Finder" and title == ""
    return "<div class='content empty'></div>"

  # else show window + title
  windowSpan = "<span class='window'>#{win}</span>"
  titleSpan = "<span class='title'>#{titleSubs}</span>"

  out = "#{windowSpan}"
  if titleSubs
    out += " / #{titleSpan}"

  return "<div class='content'>#{out}</div>"

style: """
  .content
    position: absolute
    top: 0
    left: 10px
    font: 13px Osaka-Mono
    color: #555
    z-index: 2
    height: 26px
    background-color: #111
    line-height: 26px
    min-width: 200px
    white-space: nowrap

  .empty
    min-width: 0
    height: 0

  span.window
    color: #aaa
    min-width: 200px
"""
