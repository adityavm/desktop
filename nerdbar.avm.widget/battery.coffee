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
			background-color: #C5992C
			color: #333
			padding: 0 5px

			.label
				color: rgba(#000, 0.25)

		&.charging
			color: #C5992C

		&.finishing.charge
			color: #B5C625

		&.charged
			color: #8EC620

	span.label
		color: #555

"""
