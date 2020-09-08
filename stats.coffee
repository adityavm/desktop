#
# stack
#

_widget = null
widget = [3, 35, false]
maxHeight = 13

#
# widget
#

command: (cb) ->
  self = this
  cmd = "echo $(ps -A -o %mem | awk '{s+=$1} END {print \"\" s}'),$(ps -A -o %cpu | awk '{s+=$1} END {printf(\"%.2f\",s/8);}')"

  $.getScript "lib/dynamic.js", (stack) ->
    _widget = nbWidget(widget[0], widget[1], widget[2])
    self.run(cmd, cb)

refreshFrequency: 5000 # ms

render: (output) ->
  [mem, cpu] = output.trim().split(",").map(parseFloat)

  cpuC = switch
    when cpu > 25 then "high"
    when cpu > 50 then "veryhigh"
    else "low"
  memC = switch
    when mem < 70 then "high"
    when mem < 50 then "veryhigh"
    else "low"

  # bars
  # """
  # <span class="#{cpuC}" style="height:#{cpu*0.3}%"></span>
  # <span class="#{memC}" style="height:#{mem*0.3}%"></span>
  # """

  # minimalist
  """
  <span class="bullet #{cpuC}">&bull;</span>
  <span class="bullet #{memC}">&bull;</span>
  """

afterRender: (domEl) ->
  _widget.domEl domEl
  $(domEl).css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

style: """
  color: rgba(#aaa, 0.5)
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  bottom: 10px
  height: 40px
  line-height: 26px
  text-align: center
  display: flex
  align-items: center
  justify-content: center
  background-color: #232021
  border-radius: 5px
  padding: 0 10px;
  margin-right: 10px

  &.hidden
    display: none

  span
    margin-bottom: 10px
    width: 4px
    background-color: #aaa

    &.bullet
      margin-bottom: 0
      background-color: transparent
      color: #aaa

    &.high
      background-color: #feb46b

      &.bullet
        background-color: transparent
        color: #feb46b

    &.veryhigh
      background-color: #eb806b

      &.bullet
        background-color: transparent
        color: #eb806b

    & + span
      margin-left: 2px

"""
