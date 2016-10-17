command: "pmset -g batt | egrep '([0-9]+\%).*' -o --colour=auto | cut -f1 -d';'"

refreshFrequency: 150000 # ms

render: (output) ->
  "<span class='content'><span class='label'>bat</span> <span class='charge'>#{output}</span></span></span>"

afterRender: (domEl) ->
	out = ""

	@run "pmset -g batt", (err, resp) ->
		out = resp.split ";"
		$(domEl).find(".content").addClass(out[1])

style: """
	font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
	top: 0
	right: 145px
	height: 26px

	span.content
		display: inline-block
		line-height: 26px
		height: 26px
		color: #8EC620

		&.discharging
			background-color: #ecb512
			color: #333
			padding: 0 5px

			.label
				color: rgba(#000, 0.25)

		&.charging
			color: #ecb512

		&.finishing.charge
			color: #b5c625

		&.charged
			color: #88c625

	span.label
		color: #555

"""
