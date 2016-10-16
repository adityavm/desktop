command: "date +\"%H:%M\""

refreshFrequency: 10000 # ms

render: (output) ->
  "#{output}"

style: """
  color: #95c25b
  font: 12px Osaka-Mono
  right: 15px
  top: 6px
"""
