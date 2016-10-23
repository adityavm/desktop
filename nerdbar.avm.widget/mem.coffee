#
# stack
#

widget = [3, 70, true]
updateNBW = (visible = true) ->
  window.nerdbarStack = if !window.nerdbarStack then [] else window.nerdbarStack
  widget[2] = visible
  nerdbarStack[widget[0]] = widget

getRight = () ->
  left = 0
  window.nerdbarStack = if !window.nerdbarStack then [] else window.nerdbarStack
  for i in window.nerdbarStack
    if i and i[2] == true and i[0] < widget[0] then left += i[1]

  return left

getWidth = () -> widget[1]

updateNBW true

#
# widget
#

command: "ESC=`printf \"\e\"`; ps -A -o %mem | awk '{s+=$1} END {print \"\" s}'"

refreshFrequency: 10000 # ms

render: (output) ->
  "mem <span>#{output}</span>"

afterRender: (domEl) ->
  $(domEl).css({ right: getRight() + "px", width: getWidth() + "px" })

style: """
  color: #555
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  top: 0
  height: 26px
  line-height: 26px
  text-align: center

  span
    color: #aaaaaa
"""
