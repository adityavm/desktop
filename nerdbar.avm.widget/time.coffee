#
# stack
#

widget = [0, 60, true]
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

command: "date +%H:%M"

refreshFrequency: 10000 # ms

render: (output) ->
	time = output.split ":"
	hrs = parseInt time[0]
	min = parseInt time[1]

	suffix = if hrs > 12 then "p" else "a"

	hrs = if hrs > 12 then hrs - 12 else hrs
	min = if min < 10 then "0#{min}" else min

	"#{hrs}:#{min}#{suffix}"

afterRender: (domEl) ->
  $(domEl).css({ right: getRight() + "px", width: getWidth() + "px" })

style: """
  color: #94d5e4
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  top: 0
  height: 26px
  line-height: 26px
  text-align: center
"""
