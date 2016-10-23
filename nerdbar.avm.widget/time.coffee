#
# stack
#

_widget = null
widget = [0, 50, true]

#
# widget
#

command: (cb) ->
  self = this
  cmd = """date +%H:%M"""

  $.getScript "nerdbar.avm.widget/lib/dynamic.js", (stack) ->
    _widget = nbWidget(widget[0], widget[1], widget[2])
    self.run(cmd, cb)

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
  _widget.domEl domEl
  $(domEl).css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

style: """
  color: #94d5e4
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  top: 0
  height: 26px
  line-height: 26px
  text-align: center
"""
