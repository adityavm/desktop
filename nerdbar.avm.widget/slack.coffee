#
# stack
#

_widget = null
widget = [6, 60, true]

#
# globals
#

impTypes = []
impChannels = []
impChannelsID = {}
domEl = null
socket = null
retry = null


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

	# if non-message, message from self or bot
	if typ != "message" or msg.user == cfg.SLACK_SELF_ID or msg.bot_id then return

	if msg.type == "message"
		if msg.subtype != "message_deleted" and msg.subtype != "message_changed"
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
		impTypes = cfg.TYPES
		impChannels = cfg.CHANNELS

		$.getScript "nerdbar.avm.widget/lib/dynamic.js", (stack) ->
			_widget = nbWidget.apply null, widget

			self.run("""curl -s https://slack.com/api/rtm.start?token=#{cfg.SLACK_TOKEN}&simple_latest=true""", cb)

refreshFrequency: false

render: (output) ->
	console.log """got output, length: #{output.length}"""

	self = this
	err = false

	# try and parse the response . this will erorr
	# if slack api throws up . keep retrying until
	# we get a successful response .

	try
		json = JSON.parse output
	catch e
		err = true
		console.error e
		if !retry
			retry = setInterval((() -> self.refresh()), cfg.RETRY_INTERVAL) # retry
			console.warn "starting retry timer"
		return

	if !err
		if !!retry
			clearInterval retry
			retry = null
	else
		return

	console.log "%cconnected", "color: #7aab7e", "cleared interval (is now '#{retry}'), continuing ..."

	# assign self
	cfg.SLACK_SELF_ID = json.self.id

	console.log "%cinfo", "color: #53d1ed", "got self, setting #{cfg.SLACK_SELF_ID}"

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
	_widget.domEl el
	$(domEl).css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

style: """
	font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
	right: 395px
	top: 0
	height: 26px
	line-height: 26px
	text-align: center
	width: 65px
	color: #555
	opacity: 0
	transition: opacity 0.2s

	&.show
		opacity: 1

	.unread
		color: #aaa

		.channels
			color: #aaaaaa
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
