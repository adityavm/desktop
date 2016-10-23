#
# stack
#

widget = [5, 60, true]
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

command: "ESC=`printf \"\e\"`; ps -A -o %cpu | awk '{s+=$1} END {printf(\"%.2f\",s/8);}'"

refreshFrequency: 2000

render: (output) ->
  floatVal = parseFloat output
  str = ""

  if floatVal > 75
    str = "cpu <span class='red'>#{output}</span>"
  else if floatVal > 45
    str = "cpu <span class='orange'>#{output}</span>"
  else if floatVal > 0
    str = "cpu <span class='green'>#{output}</span>"

  str

afterRender: (domEl) ->
  $(domEl).css({ right: getRight() + "px", width: getWidth() + "px" })

style: """
  color: #555
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  top: 0
  height: 26px
  line-height: 26px
  text-align: center

  span.green
    color: #88c625

  span.orange
    color: #ff8000

  span.red
    color: #ec3f1d
"""
