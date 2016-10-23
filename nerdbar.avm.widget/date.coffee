#
# stack
#

widget = [1, 80, true]
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

command: "date +\"%a %d %b\""

refreshFrequency: 10000

render: (output) ->
  "#{output}"

afterRender: (domEl) ->
  $(domEl).css({ right: getRight() + "px", width: getWidth() + "px" })

style: """
  color: #ee6aa0
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  top: 0
  height: 26px
  line-height: 26px
  text-align: center
"""
