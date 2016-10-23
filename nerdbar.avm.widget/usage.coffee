#
# stack
#

widget = [4, 50, true]
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

command: "/usr/local/bin/node ~/dev/bitbar-plugins/node/usage.uebersicht.js"

refreshFrequency: "1h"

render: (output) ->
	json = JSON.parse output
	cls = ""

	if json.usageLeft < 5
		cls = "low"

	if json.usageLeft >= 5
		cls = "ok"

	if json.usageLeft > 8
		cls = "high"

	"<span class='label'>gbs</span><span class='usage #{cls}'>#{json.symbol}</span><span class='usage-value'>#{json.usageLeft} gbs/day</span>"

afterRender: (domEl) ->
  $(domEl).css({ right: getRight() + "px", width: getWidth() + "px" })


style: """
	font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
	height: 26px
	line-height: 26px
	top: 0
	color: #555
	display: flex
	user-select: none
	justify-content: center

	.usage-value
		position: absolute
		right: 0
		bottom: -60px
		width: 80px
		text-align: right
		background-color: #111
		padding: 0 10px
		display: inline-block
		opacity: 0
		transition: opacity 0.2s

		&:before
			border: 5px solid #111
			border-color: transparent transparent #111
			content: " "
			position: absolute
			top: -10px
			right: 5px

	&:active .usage-value
		opacity: 1

	span.usage
		color: #aaa
		font-size: 20px

	span.low
		color: #ec3f1d

	span.ok
		color: #ecb512

	span.high
		color: #88c625
"""
