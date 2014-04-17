# TRIGGERS
d3.trigger = (d3Obj, evtName) ->
		el    = d3Obj[0][0]
		event = d3.event;

		if event.initMouseEvent
			clickEvent = document.createEvent 'MouseEvent'
			clickEvent.initMouseEvent "click", true, true, window, 0, event.screenX, event.screenY, event.clientX, event.clientY, event.ctrlKey, event.altKey, event.shiftKey, event.metaKey, 0, null
			el.dispatchEvent clickEvent
		else
			if document.createEventObject
				clickEvent = document.createEventObject window.event
				clickEvent.button = 1
				el.fireEvent evtName, clickEvent

isMobile = ->
  check = false
  ((a) ->
    check = true  if /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a) or /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))
    return
  ) navigator.userAgent or navigator.vendor or window.opera
  check


chart =
	el: null
	getDimensions: () ->
		if isMobile() then window.innerWidth - 40
		else if (window.innerWidth - 360) < window.innerHeight && (window.innerWidth - 360) > 500 then window.innerWidth - 360
		else if (window.innerHeight - 60) > 500 then window.innerHeight - 60
		else 500
	rootCircle: null
	mainCircle: null
	radius: () -> Math.min(chart.getDimensions(), chart.getDimensions()) / 2
	init: () ->
		@el = d3.select 'svg'
			.attr 'width', chart.getDimensions()
			.attr 'height', chart.getDimensions()
			.append 'g'
			.attr 'class', 'main'
			.attr 'transform', 'translate(' + chart.getDimensions() / 2 + ',' + (chart.getDimensions() / 2) + ')'
			.on 'mouseleave', chart.onMouseleave
		@mainCircle = @rootCircle
		tooltip.show(chart.rootCircle)
		breadcrumb.create(chart.rootCircle)
	onMouseover: (d) ->
		chart.highlight(@)
		tooltip.show(d)
	onMouseleave: (d) ->
		chart.highlightAll()
		tooltip.show(chart.mainCircle)
	highlight: (el) ->
		if el.classList.contains 'current'
			chart.highlightAll()
		else
			d3.selectAll '.arc'
				.transition()
				.style 'opacity', 0.6
			d3.select el
				.transition()
				.style 'opacity', 1
	highlightAll: () ->
		d3.selectAll '.arc'
			.transition()
			.style 'opacity', 1
	zoomIn: (d) ->
		chart.mainCircle = d
		path.transition()
			.duration 750
			.attrTween 'd', arcTween(d)
		breadcrumb.update breadcrumb.getAncestors(d)
		d3.selectAll '.arc'
			.classed 'current', false
		d3.select @.parentNode
			.classed 'current', true
		d3.selectAll '.main-circle'
			.classed 'visible', false
		d3.select @.nextElementSibling
			.classed 'visible', true
		d3.selectAll 'path'
			.style 'opacity', '1'
		d3.selectAll 'path.' + classes.getLevel(d.depth)
			.style 'opacity', '0'
		d3.select @
			.style 'opacity', '1'
		chart.highlightAll()

partition = d3.layout.partition()
	.value (d) ->
		Math.abs Math.round d.values[0]
	.sort (a, b) -> return d3.ascending(a.name, b.name)
# arc1 = d3.svg.arc()
# 	.startAngle (d) ->
# 		# console.log(2 * Math.PI, x(d.x))
# 		Math.max 0, Math.min(2 * Math.PI, x(d.x))
# 	.endAngle (d) -> Math.max 0, Math.min(2 * Math.PI, x(d.x + d.dx))
# 	.innerRadius (d) ->
# 		# if d is chart.mainCircle then Math.max 0, y(d.y)
# 		# else Math.max 100, y(d.y)
# 		Math.max(0, y(d.y))
# 	.outerRadius (d) ->
# 		# if d is chart.mainCircle then Math.max 100, y(d.y + d.dy)
# 		# else Math.max 0, y(d.y + d.dy)
# 		Math.max( 0, y(d.y + d.dy))

arc = d3.svg.arc()
	.startAngle (d) ->
		# console.log(d, Math.min(2 * Math.PI, x(d.x)))
		Math.max 0, Math.min(2 * Math.PI, x(d.x))
	.endAngle (d) -> Math.max 0, Math.min(2 * Math.PI, x(d.x + d.dx))
	.innerRadius (d) ->
		if d is chart.mainCircle then Math.max 0, y(d.y) 
		else if d.depth is chart.mainCircle.depth + 1 then Math.max 100, y(d.y)
		# else if d.depth is chart.mainCircle.depth - 1 then 0
		else Math.max 0, y(d.y)
		# Math.max 0, y(d.y)
	.outerRadius (d) ->
		if d is chart.mainCircle then Math.max 100, y(d.y + d.dy)
		# else if d.depth is chart.mainCircle.depth + 1 then Math.max 100, y(d.y + d.dy)
		# else if d.depth is chart.mainCircle.depth - 1 then 0
		else Math.max 100, y(d.y + d.dy)
		# Math.max 0, y(d.y + d.dy)

path = null

# COLORS
colors =
	positive: ['#1DC2F7', '#1BB6E8', '#1AAEDE', '#18A2CF', '#1696BF', '#1A8BB3', '#127899', '#136480', '#0E5066','#0B3C4D']
	negative: ['#ff747d', '#f5646d', '#ef5761', '#eb4c56', '#df4650', '#d23c46', '#c4343d', '#b72b34', '#a9242d', '#9a1b23']
	scale: null # initialized with the API call
	getColor: (nb) ->
		if nb < 0 then colors.negative[colors.scale.negative(nb)]
		else colors.positive[colors.scale.positive(nb)]

# CLASSES
classes =
	levels: ['root', 'level-one', 'level-two', 'level-three', 'level-four', 'level-five', 'level-six']
	getLevel: (nb) ->
		@levels[nb]
	getSign: (nb) ->
		if nb < 0 then 'negative' else 'positive'


# BREADCRUMB
breadcrumb =
	el: d3.select '#breadcrumb'
	create: (node) ->
		@el.select 'ul'
			.append 'li'
				.each () ->
					d3.select this
						.append 'span'
						.attr 'class', 'breadcrumb--value'
						.style 'background', colors.getColor(node.values[0])
						.append 'div'
						.attr 'class', 'reflect'
					d3.select this
						.append 'h2'
						.attr 'class', 'breadcrumb--label'
						.text (d) ->
							if node.name.length > 25 then node.name.substring(0, 24) + '...'
							else node.name
				.on 'click', () ->  breadcrumb.navigate node.code
	update: (path) ->
		@el.select 'ul'
			.html('')
		breadcrumb.create(chart.rootCircle)
		path.forEach (node) ->
			breadcrumb.create(node)
	getAncestors: (node) ->
		steps = []
		current = node
		while current.parent
			steps.unshift current # unshift -> beginning of the array != push()
			current = current.parent
		steps
	navigate: (code) ->
		d3.trigger d3.select('path[data-code=' + code + ']'), 'click'
	return: (node) ->
		d3.trigger d3.select('path[data-code=' + node.parent.code + ']'), 'click'

# TOOLTIP
tooltip =
	el: d3.select '#tooltip'
	width: () -> @el[0][0].scrollWidth
	height: () -> @el[0][0].scrollHeight
	show: (d) ->
		tooltip.el.select '.tooltip--label'
			.text d.name
		tooltip.el.select '.tooltip--value'
			.text Math.round(d.values[0]).toLocaleString('fr') + ' €'
			.style 'color', colors.getColor(d.values[0])
		tooltip.el.select '.tooltip--find-out-more'
			.attr 'href', d.url

# CONSTANTS

x = d3.scale.linear()
	.range [0, 2 * Math.PI]
y = d3.scale.sqrt()
	.range [0, chart.radius()]


arcTween = (d) ->
	xd = d3.interpolate x.domain(), [d.x, d.x + d.dx]
	yd = d3.interpolate y.domain(), [d.y, 1]
	yr = d3.interpolate y.range(), [0, chart.radius()]
#	yr = d3.interpolate y.range(), [(if d.y then 20 else 0), radius]
	(d, i) ->
		(if i then (t) ->
			# arc1 d
			arc d
		else (t) ->
			x.domain xd(t)
			y.domain(yd(t)).range yr(t)
			arc d)

# API KEY
getApiKey = () ->
	string = window.location.search.substring(1)
	key = string.split '='
	key = decodeURIComponent key[1]
	key

url = getApiKey()

# API
d3.json url, (error, root) ->
	data = root.value
	# INITIALIZATION
	values =
		negative: []
		positive: []

	tempValues = partition.nodes data
	tempValues.forEach (d, i) ->
		if d.depth == 0 then chart.rootCircle = d
		if d.values[0] < 0 then values.negative.push(d.values[0])
		else if d.values[0] != 0 then values.positive.push(d.values[0])

	colors.scale =
		negative: d3.scale.linear().domain([d3.max(values.negative), d3.min(values.negative)]).rangeRound([0, 9])
		positive: d3.scale.linear().domain([d3.min(values.positive), d3.max(values.positive)]).rangeRound([0, 9])

	chart.init()


	path = chart.el.selectAll 'path'
		.data (partition.nodes data).filter((d) -> return d.values[0] != 0)
		.enter()
		.append 'g'
		.attr 'class', (d) -> if d.depth is 0 then 'arc current' else 'arc'
		.on 'mouseover', chart.onMouseover
		.append 'path'
		.attr 'class', (d) -> classes.getLevel(d.depth)
		.attr 'data-code', (d) -> d.code
		.attr 'd', arc
		.style 'fill', (d) -> colors.getColor(d.values[0])
		.on 'click', chart.zoomIn
		# .on 'mousemove', tooltip.update
		# .on 'mouseout', tooltip.hide
		.each (d) ->
			d3.select this.parentNode
				.append 'svg:text'
				.attr 'class', 'main-circle--label'
				.attr 'y', '-20'
				.text((d) -> d.name)
			d3.select this.parentNode
				.append 'svg:text'
				.classed('main-circle--value', true)
				.classed('number', true)
				.attr 'y', '20'
				.text((d) -> Math.round(d.values[0]).toLocaleString('fr') + ' €')
			d3.select this.parentNode
				.filter((d) -> return d.depth != 0)
				.append 'image'
				.classed('return', true)
				.attr 'xlink:href', 'images/icon-return.png'
				.attr 'width', '35'
				.attr 'height', '35'
				.attr 'x', '-17.5'
				.attr 'y', '35'
				.on 'click', () -> breadcrumb.return d
			# d3.select this.parentNode
			# 	.append 'foreignObject'
			# 	.attr 'class', 'main-circle'
			# 	.classed('visible', (if d.depth == 0 then true else false))
			# 	.attr 'x', () -> (chart.getDimensions() / 2.63) / 2 * -1
			# 	.attr 'y', () -> (chart.getDimensions() / 2.63) / 2 * -1
			# 	.attr 'width', () -> chart.getDimensions() / 2.63
			# 	.attr 'height',() -> chart.getDimensions() / 2.63
			# 	.append 'xhtml:div'
			# 	.style 'width', () -> chart.getDimensions() / 2.63 + 'px'
			# 	.style 'height', () -> chart.getDimensions() / 2.63 + 'px'
			# 	.append 'div'
			# 	# Append all labels
			# 	.each (d) ->
			# 		d3.select this
			# 			.append 'h1'
			# 			.attr 'class', 'main-circle--label'
			# 			.text (d) -> d.name
			# 		d3.select this
			# 			.append 'p'
			# 			.attr 'class', 'main-circle--value number'
			# 			.text (d) -> Math.round(d.values[0]).toLocaleString('fr') + ' €'
			# 		d3.select this
			# 			.append 'button'
			# 			.attr 'class', 'return'
			# 			.classed('visible', (if d.depth > 0 then true else false))
			# 			.on 'click', () -> breadcrumb.return d

	return

d3.select '.null'
	.remove()
