
#
# stack
#

_widget = null
widget = [6, 250, true]
domElem = null
SONGNAMELIMIT = 15

#
# widget
#

command: (cb) ->
  self = this
  cmd = """osascript -e 'if application "iTunes" is running then tell application "iTunes" to if player state is playing then "[\\\"" & name of current track & "\\\",\\\"" & artist of current track & "\\\"]"'"""

  $.getScript "nerdbar.avm.widget/lib/dynamic.js", (stack) ->
    _widget = nbWidget(widget[0], widget[1], widget[2])
    self.run(cmd, cb)

refreshFrequency: 5000

render: (output) ->
  out = ["", ""]
  try
    out = JSON.parse output
  catch e

  song = out[0] + if out[0].length > SONGNAMELIMIT then "&hellip;" else ""
  artist = out[1]
  if song == "" and artist == ""
    _widget.update false
  else
    _widget.update true

  """song <span class="song">#{song}</span> <span class="artist">#{artist}</span>"""

afterRender: (domEl) ->
  domElem = domEl
  _widget.domEl domEl
  $(domEl).css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

style: """
  color: #333
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  top: 0
  height: 26px
  line-height: 26px
  text-align: right
  transition: opacity 0.2s
  opacity: 1

  &.hidden
    opacity: 0

  .artist
    display: inline-block
    transform-origin: 0 75%
    color: #888573
    opacity: 0.75
    -webkit-font-smoothing: antialiased
    transform: scale(0.8)

  .song
    color: #888573
    margin-left: 5px
"""
