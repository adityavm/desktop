command: "date +%H:%M"

refreshFrequency: 10000 # ms

render: (output) ->
	time = output.split ":"
	hrs = parseInt time[0]
	min = parseInt time[1]

	suffix = if hrs > 12 then "p" else "a"

	hrs = if hrs > 12 then hrs - 12 else hrs

	"#{hrs}:#{min}#{suffix}"

style: """
  color: #95c25b
  font: 12px "SFNS Display", Osaka-Mono, Hack, Inconsolata
  right: 15px
  top: 6px
"""
