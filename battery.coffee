#
# stack
#

_widget = null
widget = [2, 70, true]

#
# internal
#

# width class based on output value
getWidthCls = (output) ->
  widthCls = ""
  outputInt = parseInt output

  if outputInt >= 0   then widthCls = "w0"
  if outputInt >= 25 then widthCls = "w25"
  if outputInt >= 50 then widthCls = "w50"
  if outputInt >= 75 then widthCls = "w75"
  if outputInt == 100 then widthCls = "w100"

  widthCls

getMeter = (output) ->
  outputInt = parseInt output

  outArray = [1..Math.floor(outputInt / 20)]
  return outArray.map((i) -> "•").join("")

isLow = (output) ->
  outputInt = parseInt output
  return outputInt < 50

#
# widget
#

command: (cb) ->
  self = this
  cmd = "pmset -g batt | egrep '([0-9]+\%).*' -o --colour=auto | cut -f1 -d';'"

  $.getScript "lib/dynamic.js", (stack) ->
    _widget = nbWidget(widget[0], widget[1], widget[2])
    self.run(cmd, cb)

refreshFrequency: 60000 # ms

render: (output) ->
  """
  <span class='content'>
    <span class='label text'>
      <span class='battery icon'></span>
      <span class='text'>bat</span>
    </span>
    <span class='charge' title="#{output}">#{getMeter(output)}</span>
  </span>
  """

update: (output, domEl) ->
  _widget.domEl domEl

  # class / text manip
  widthCls = getWidthCls output
  $(domEl).find(".battery.icon").addClass widthCls
  $(domEl).find(".charge").text getMeter(output)

  # get charging progress
  @run "pmset -g batt", (err, resp) ->
    out = resp.split ";"

    # _widget.update(out[1].trim() != "charged")

    $(domEl).find(".content").removeClass("discharging charging finishing charge charged").addClass(out[1])
    $(domEl).find(".content").removeClass("low").addClass(if isLow(output) then "low" else "")

afterRender: (domEl) ->
  _widget.domEl domEl
  $(domEl).css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

style: """
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  bottom: 17px
  height: 26px
  text-align: center

  &.hidden
    display: none

  span.content
    display: inline-block
    line-height: 26px
    height: 26px
    color: #fff
    padding: 0 5px

    &.discharging
      color: #aaa

      .label
        background-color: #ecb512

    &.charging
      color: #ecb512 !important

    &.finishing.charge
      color: #b5c625

    &.charged
      color: #88c625

    &.low
      background-color: red
      color: #111

      &.charging
        background-color: transparent
        color: red

  span.label
    width: 15px
    display: none
    position: relative
    color: rgba(#aaa, 0.5)

    &.text
      margin-right: 3px

      .icon
        display: none

    &.icon
      .text
        display: none

    .battery.icon
      position: absolute
      margin-left: -2px
      margin-top: -8px
      width: 13px
      height: 7px
      border-radius: 2px
      border: solid 1px currentColor

      &:before
        content: ''
        position: absolute
        right: -3px
        top: 1px
        width: 2px
        height: 3px
        border-radius: 0 2px 2px 0
        border-top: solid 1px currentColor
        border-right: solid 1px currentColor
        border-bottom: solid 1px currentColor

      &:after
        content: ''
        position: absolute
        left: 0
        top: 0
        height: 7px
        width: 0
        background-color: currentColor
        transition: width 0.2s

      &.w0:after
        width: 1px

      &.w25:after
        width: 4px

      &.w50:after
        width: 7px

      &.w75:after
        width: 10px

      &.w100:after
        width: 13px
"""
