command: "ESC=`printf \"\e\"`; ps -A -o %mem | awk '{s+=$1} END {print \"\" s}'"

refreshFrequency: 30000 # ms

render: (output) ->
  "mem <span>#{output}</span>"

style: """
  color: #555
  font: 12px Osaka-Mono
  right: 197px
  top: 6px
  span
    color: #9C9486
"""
