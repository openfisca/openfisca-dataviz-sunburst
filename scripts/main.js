// Generated by CoffeeScript 1.7.1
(function() {
  var arc, arcTween, color, colors, height, hideTooltip, partition, radius, showTooltip, svg, tooltip, tooltipH, tooltipW, updateTooltip, width, x, y;

  arcTween = function(d) {
    var xd, yd, yr;
    xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]);
    yd = d3.interpolate(y.domain(), [d.y, 1]);
    yr = d3.interpolate(y.range(), [(d.y ? 20 : 0), radius]);
    return function(d, i) {
      if (i) {
        return function(t) {
          return arc(d);
        };
      } else {
        return function(t) {
          x.domain(xd(t));
          y.domain(yd(t)).range(yr(t));
          return arc(d);
        };
      }
    };
  };

  tooltip = d3.select('#tooltip');

  tooltipW = tooltip[0][0].scrollWidth;

  tooltipH = tooltip[0][0].scrollHeight;

  console.log(tooltip, tooltipW);

  showTooltip = function(d) {
    tooltip.transition().duration(300).style('opacity', 1);
    tooltip.select('#tooltip--label').text(d.name);
    return tooltip.select('#tooltip--value').text(d.value.toLocaleString('fr') + ' €');
  };

  updateTooltip = function() {
    console.log(d3.event);
    tooltip.style('top', d3.event.pageY - (tooltipH + 10) + 'px');
    return tooltip.style('left', (d3.event.pageX - tooltipW / 2) + 'px');
  };

  hideTooltip = function() {
    return tooltip.transition().duration(300).style('opacity', 1e-6);
  };

  colors = {
    positive: ['#1DC2F7', '#1BB6E8', '#1AAEDE', '#18A2CF', '#1696BF', '#1A8BB3', '#127899', '#136480', '#0E5066', '#0B3C4D'],
    negative: ['#ff747d', '#f5646d', '#ef5761', '#eb4c56', '#df4650', '#d23c46', '#c4343d', '#b72b34', '#a9242d', '#9a1b23']
  };

  width = 700;

  height = 700;

  radius = Math.min(width, height) / 2;

  x = d3.scale.linear().range([0, 2 * Math.PI]);

  y = d3.scale.sqrt().range([0, radius]);

  color = d3.scale.category20c();

  svg = d3.select('body').append('svg').attr('width', width).attr('height', height).append('g').attr('transform', 'translate(' + width / 2 + ',' + (height / 2) + ')');

  partition = d3.layout.partition().value(function(d) {
    d.values[0] = Math.abs(Math.round(d.values[0]));
    return d.values[0];
  });

  arc = d3.svg.arc().startAngle(function(d) {
    return Math.max(0, Math.min(2 * Math.PI, x(d.x)));
  }).endAngle(function(d) {
    return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx)));
  }).innerRadius(function(d) {
    return Math.max(0, y(d.y));
  }).outerRadius(function(d) {
    return Math.max(0, y(d.y + d.dy));
  });

  d3.json('data/example.json', function(error, root) {
    var onClick, path;
    root = root.value;
    console.log(root);
    onClick = function(d) {
      return path.transition().duration(750).attrTween('d', arcTween(d));
    };
    path = svg.selectAll('path').data(partition.nodes(root)).enter().append('path').attr('data-name', function(d) {
      return d.name;
    }).attr('data-value', function(d) {
      return Math.round(d.values[0]);
    }).attr('class', function(d) {
      if (d.values[0] > 0) {
        return 'positive';
      } else {
        return 'negative';
      }
    }).attr('d', arc).style('fill', function(d) {
      return color((d.children ? d : d.parent).name);
    }).on('click', onClick).on('mouseover', showTooltip).on('mousemove', updateTooltip);
  });

  d3.select(self.frameElement).style('height', height + 'px');

}).call(this);
