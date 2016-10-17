command: "ESC=`printf \"\e\"`; ps -A -o %mem | awk '{s+=$1} END {print \"\" s}'"

refreshFrequency: 30000 # ms

render: (output) ->
  "mem <span>#{output}</span>"

style: """
  color: #555
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  right: 210px
  top: 0
  height: 26px
  line-height: 26px

  span
    color: #9C9486
"""
