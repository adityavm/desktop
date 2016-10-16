options =
  refresh: 1000
  cutOff: 60

command: "osascript active-window.widget/lib/window_title.scpt"

refreshInterval: 1000,

render: (output) ->
  split = output.match /(.+),(.+)/
  window = split[1].trim()
  title = split[2].trim()
  titleSubs = if title.length > options.cutOff then "&hellip;" + title.substr title.length - options.cutOff, title.length else title

  windowSpan = "<span class='window'>#{window}</span>"
  titleSpan = "<span class='title'>#{titleSubs}</span>"

  out = "#{windowSpan}"
  if titleSubs
    out += " / #{titleSpan}"

  out

style: """
  font: 11px Hack
  color: #555
  top: 6px
  left: 10px

  span.window
    color: #aaa
"""
