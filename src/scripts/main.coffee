# TRIGGERS
d3.trigger = (d3Obj, evtName) ->
		console.log(d3Obj);
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


# CONSTANTS
width = 500
height = 500
widthRoot = width / 2.63 # random, should be optimized
heightRoot = height / 2.63
radius = Math.min(width, height) / 2
x = d3.scale.linear()
	.range [0, 2 * Math.PI]
y = d3.scale.sqrt()
	.range [0, radius]


chart = 
	highlight: (d) ->
		# tooltip.show(d)
		# d3.selectAll 'path'
		# 	.style 'opacity', 0.4
		# d3.select this
		# 	.style 'opacity', 1
	highlightAll: (s) ->
		### TO FIX : on hover, the path animation stops ###
		# # Deactivate all segments during transition.
		# d3.selectAll 'path'
		# 	.on 'mouseover', null
		# # Transition each segment to full opacity and then reactivate it.
		# d3.selectAll 'path'
		# 	.transition()
		# 	.duration(750)
		# 	.style 'opacity', 1
		# 	.each 'end', () -> 
		# 		d3.select this
		# 			.on 'mouseover', chart.highlight

svg = d3.select 'svg'
	.attr 'width', width
	.attr 'height', height
	.append 'g'
	.attr 'transform', 'translate(' + width / 2 + ',' + (height / 2) + ')'
	.on 'mouseleave', chart.highlightAll
partition = d3.layout.partition()
	.value (d) -> 
		Math.abs Math.round d.values[0]
	.sort (a, b) -> return d3.ascending(a.name, b.name) 
arc = d3.svg.arc()
	.startAngle (d) -> Math.max 0, Math.min(2 * Math.PI, x(d.x))
	.endAngle (d) -> Math.max 0, Math.min(2 * Math.PI, x(d.x + d.dx))
	.innerRadius (d) -> Math.max 0, y(d.y)
	.outerRadius (d) -> Math.max 0, y(d.y + d.dy)

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
	li: d3.select '#breadcrumb li'
	create: (node) ->
		@el.select 'ul'
			.append 'li'
				.on 'click', () ->  breadcrumb.navigate node.code
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
						.text node.name
				.attr 'class', 'visible'
				.attr 'data-depth', node.depth
	update: (path) ->
		@el.select 'ul'
			.html('')
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
		tooltip.el.transition()
			# .delay 500
			.duration 300
			.style 'opacity', 1
		tooltip.el.select '.tooltip--label'
			.text d.name
		tooltip.el.select '.tooltip--value'
			.text Math.round(d.values[0]).toLocaleString('fr') + ' €'
			.style 'color', colors.getColor(d.values[0]) 
	# update: () ->
	# 	tooltip.el.style 'top', d3.event.pageY - (tooltip.height() + 5) + 'px'
	# 	tooltip.el.style 'left', (d3.event.pageX - tooltip.width() / 2) + 'px'
	# hide: () ->
	# 	tooltip.el.transition()
	# 		.duration 300
	# 		.style 'opacity', 1e-6
	# onMouseover: () ->
	# 	tooltip.el.transition()
	# 		.duration 300
	# 		.style 'opacity', 1
	# onMouseout: () ->
	# 	tooltip.el.style 'opacity', 0

arcTween = (d) ->
	xd = d3.interpolate x.domain(), [d.x, d.x + d.dx]
	yd = d3.interpolate y.domain(), [d.y, 1]
	yr = d3.interpolate y.range(), [0, radius]
#	yr = d3.interpolate y.range(), [(if d.y then 20 else 0), radius]
	(d, i) ->
		(if i then (t) ->
			arc d
		else (t) ->
			x.domain xd(t)
			y.domain(yd(t)).range yr(t)
			arc d)


zoomIn = (d) ->
	# append label in root-circle
	d3.selectAll '.root-circle--content'
		.classed('visible', false)
	d3.select this.nextElementSibling
		.classed('visible', true)
	breadcrumb.update breadcrumb.getAncestors(d)
	path.transition()
		.duration 750
		.attrTween 'd', arcTween(d)
	# hide/unhide root label
	d3.select '.root-circle--content'
		.style 'opacity', 0
		.style 'display', 'none'
	if breadcrumb.getAncestors(d).length == 0
		d3.select '.root-circle--content'
		.style 'opacity', 1
		.style 'display', 'block'
	# when former 'root hole' is hidden, delete thin line :
	# # hide other parts of the zoomed arc
	# # unhide previously hidden parts
	d3.selectAll 'path'
		.style 'opacity', '1'
	# # show only the selected part of the arc
	d3.selectAll 'path.' + classes.getLevel(d.depth)
		.style 'opacity', '0'
	d3.select this
		.style 'opacity', '1'


# API
d3.json 'data/example.json', (error, root) ->
	data = root.value
	# INITIALIZATION 
	values = 
		negative: []
		positive: []

	tempValues = partition.nodes data
	tempValues.forEach (d, i) ->
		if d.values[0] < 0 then values.negative.push(d.values[0])
		else if d.values[0] != 0 then values.positive.push(d.values[0])

	colors.scale = 
		negative: d3.scale.linear().domain([d3.max(values.negative), d3.min(values.negative)]).rangeRound([0, 9])
		positive: d3.scale.linear().domain([d3.min(values.positive), d3.max(values.positive)]).rangeRound([0, 9])

	path = svg.selectAll 'path'
		.data partition.nodes data
		.enter()
		.append 'g'
		.attr 'class', (d) -> classes.getLevel(d.depth)
		.append 'path'
		.attr 'data-code', (d) -> d.code
		.attr 'class', (d) -> classes.getLevel(d.depth) + ' ' + classes.getSign(d.values[0])
		.attr 'd', arc
		.style 'display', (d) -> if d.values[0] == 0 then 'none'
		.style 'fill', (d) -> colors.getColor(d.values[0])
		.style 'opacity', (d) ->
			if d.parent and d.parent.values[0] == d.values[0] then 1
			else 1
		.on 'click', zoomIn
		.on 'mouseover', chart.highlight
		# .on 'mousemove', tooltip.update
		# .on 'mouseout', tooltip.hide
		.each (d) ->
			# if d.depth is 0
			# 	d3.select '.root'
			d3.select this.parentNode
				.append 'foreignObject'
				.attr 'class', 'root-circle--content'
				.classed('visible', (if d.depth == 0 then true else false))
				.attr 'x', widthRoot / 2 * -1
				.attr 'y', widthRoot / 2 * -1
				.attr 'width', widthRoot
				.attr 'height', heightRoot
				.append 'xhtml:div'
				.attr 'class', 'root-circle'
				.style 'width', widthRoot + 'px'
				.style 'height', widthRoot + 'px'
				.append 'div'
				.attr 'class', 'root-circle--label'
				.each (d) ->
					d3.select this
						.append 'h1'
						.attr 'class', 'root-circle--label'
						.text (d) -> d.name
					d3.select this
						.append 'p'
						.attr 'class', 'root-circle--value number'
						.text (d) -> Math.round(d.values[0]).toLocaleString('fr') + ' €'
					d3.select this 
						.append 'button'
						.on 'click', () -> breadcrumb.return d
						.attr 'class', 'return'
						.classed('visible', (if d.depth > 0 then true else false))
					tooltip.show(d)
	return



# Usage
# tooltip.el
# 	.on 'mouseover', tooltip.onMouseover
# 	.on 'mouseleave', tooltip.hide

# d3.select self.frameElement
# 	.style 'height', height + 'px'
