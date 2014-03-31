# http://bl.ocks.org/mbostock/1044242
diameter = 960
radius = diameter / 2
innerRadius = radius - 120
cluster = d2.layout.cluster()
	.size [360, innerRadius]
	.sort null
	.value (d) ->
			d.size