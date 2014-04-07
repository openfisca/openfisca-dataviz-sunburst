arcTween = (d) ->
	xd = d3.interpolate x.domain(), [d.x, d.x + d.dx]
	yd = d3.interpolate y.domain(), [d.y, 1]
	yr = d3.interpolate y.range(), [(if d.y then 20 else 0), radius]
	(d, i) ->
    (if i then (t) ->
      arc d
     else (t) ->
      x.domain xd(t)
      y.domain(yd(t)).range yr(t)
      arc d
    )
		
colors = 
	positive: ['#1DC2F7', '#1BB6E8', '#1AAEDE', '#18A2CF', '#1696BF', '#1A8BB3', '#127899', '#136480', '#0E5066','#0B3C4D']
	negative: ['#ff747d', '#f5646d', '#ef5761', '#eb4c56', '#df4650', '#d23c46', '#c4343d', '#b72b34', '#a9242d', '#9a1b23']


width = 960
height = 700
radius = Math.min(width, height) / 2
x = d3.scale.linear()
	.range [0, 2 * Math.PI]
y = d3.scale.sqrt()
	.range [0, radius]
color = d3.scale.category20c()

svg = d3.select 'body'
	.append 'svg'
	.attr 'width', width
	.attr 'height', height
	.append 'g'
	.attr 'transform', 'translate(' + width / 2 + ',' + (height / 2 + 10) + ')'
partition = d3.layout.partition()
	.value (d) -> d.size 
arc = d3.svg.arc()
	.startAngle (d) -> Math.max 0, Math.min(2 * Math.PI, x(d.x))
	.endAngle (d) -> Math.max 0, Math.min(2 * Math.PI, x(d.x + d.dx))
	.innerRadius (d) -> Math.max 0, y(d.y)
	.outerRadius (d) -> Math.max 0, y(d.y + d.dy)

d3.json 'data/flare.json', (error, root) ->
	
	onClick = (d) ->
		path.transition()
			.duration 750
			.attrTween 'd', arcTween(d)

	path = svg.selectAll 'path'
		.data partition.nodes root
		.enter()
		.append 'path'
		.attr 'd', arc
		.style 'fill', (d) -> 
			color (if d.children then d else d.parent).name
		.on 'click', onClick
	

	return


d3.select self.frameElement
	.style 'height', height + 'px'

