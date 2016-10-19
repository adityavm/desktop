#
# globals
#

impTypes = ["im"]
impChannels = ["dev", "product", "design-ux", "bug-report"]
impChannelsID = {}
domEl = null
socket = null


# initialise socket
init = (url) ->
	socket = new WebSocket url

	socket.onmessage = (ev) ->
		typ = ev.type
		msg = JSON.parse ev.data

		handle typ, msg


# handle each socket message
handle = (typ, msg) ->
	console.log msg

	# if non-message or message from self
	if typ != "message" or msg.user == cfg.SLACK_SELF_ID then return

	if msg.type == "message"
		if msg.subtype != "message_deleted" or msg.subtype != "message_changed"
			if !!impChannelsID[msg.channel]
				impChannelsID[msg.channel].unread_count += 1

	if msg.type == "channel_marked" or msg.type == "group_marked"
		console.log """channel #{msg.channel}"""
		if !!impChannelsID[msg.channel]
			console.log """marking #{msg.unread_count}"""
			impChannelsID[msg.channel].unread_count = msg.unread_count
			console.log impChannelsID

	if msg.type == "im_marked"
		console.log """marking im #{msg.dm_count}"""
		impChannelsID[msg.channel].unread_count = msg.dm_count
		console.log impChannelsID

	updateOnMsg()

	if msg.type != "message" then return

# update dom
updateOnMsg = (chn, msg) ->
	console.log "updating dom"

	els =
		unread: $(domEl).find(".unread")
		channels: $(domEl).find(".channels")
		count: $(domEl).find(".count")

	unreadChannelsCount = if chn then chn else unreadChannels()
	unreadMsgsCount = if msg then msg else unreadMsgs()

	# reset
	els.unread.removeClass("important very-busy busy")

	# set
	if unreadChannelsCount > 0
		# choose how to highlight
		hlCls = if unreadChannelsCount > 5 or unreadMsgsCount > 20 then "very-busy" else "busy"
		hlCls = if haveImportant() then "important" else hlCls

		els.unread.addClass(hlCls)
		els.channels.text(unreadChannelsCount)
		els.count.text(unreadMsgsCount)
		$(domEl).addClass("show")
	else
		$(domEl).removeClass("show")

# type channel
getType = (e) ->
	if e.is_channel then return "channel"
	if e.is_group then return "group"
	if e.is_im then return "im"

# have important messages?
haveImportant = () ->
	imp = false
	for ch, val of impChannelsID
		if val.unread_count > 0
			if impTypes.indexOf(val.type) > -1
				imp = true
				break
	return imp

# get unread channels count
unreadChannels = () ->
	sum = 0
	for ch, val of impChannelsID
		sum += if val.unread_count > 0 then 1 else 0
	return sum


# get unread messages count
unreadMsgs = () ->
	sum = 0
	for ch, val of impChannelsID
		sum += val.unread_count
	return sum

#
# widget
#

command: (cb) ->
	self = this
	$.getScript "nerdbar.avm.widget/lib/cfg.js", (data) ->
		self.run("""curl -s https://slack.com/api/rtm.start?token=#{cfg.SLACK_TOKEN}&simple_latest=true""", cb)

refreshFrequency: false

render: (output) ->
	console.log """got output, length: #{output.length}"""

	json = JSON.parse output

	# set important channels, ims + unread count
	json.channels
		.concat(json.groups)
		.filter((c) -> (impChannels.indexOf(c.name) > -1))
		.concat(json.ims)
		.map((c) ->
			impChannelsID[c.id] =
				type: getType(c)
				name: c.name
				unread_count: c.unread_count
		)

	# set initial values from rtm.start json
	unreadChannelsCount = json.channels.filter((c) -> !!impChannelsID[c.id] && c.unread_count > 0).length
	unreadMsgsCount = json.channels
		.filter((c) -> !!impChannelsID[c.id] && c.unread_count > 0)
		.reduce(((a, b) -> a.unread_count + b.unread_count), { unread_count: 0 }).unread_count

	# trigger update with forced values
	updateOnMsg(unreadChannelsCount, unreadMsgsCount)

	# initialise socket
	if (socket == null)
		init json.url
	else
		socket.close()
		socket = null
		init json.url

	"""
	slck
	<span class="unread">
		<span class="channels">0</span>
		<span class="count">0</span>
	</span>
	"""

afterRender: (el) ->
	domEl = el

style: """
	font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
	right: 395px
	top: 0
	height: 26px
	line-height: 26px
	text-align: right
	width: 65px
	color: #555
	opacity: 0
	transition: opacity 0.2s

	&.show
		opacity: 1

	.unread
		color: #aaa

		.channels
			color: #9C9486
			font-size: 14px

		&.very-busy .channels
			color: #ff8000

		&.busy .channels
			color: #ecb512

		&.important .channels
			color: #df1d1d

		.count
			font-size: 10px
			color: #aaa
"""