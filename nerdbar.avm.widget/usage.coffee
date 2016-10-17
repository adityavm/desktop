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

	"<span class='label'>gbs</span><span class='usage #{cls}'>#{json.symbol}</span>"

style: """
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  height: 26px
  line-height: 26px
  top: 0
  right: 345px
  color: #555
  display: flex

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