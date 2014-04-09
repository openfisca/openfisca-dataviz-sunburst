// Generated by CoffeeScript 1.7.1
(function() {
  var arc, arcTween, breadcrumb, classes, colors, height, heightRoot, partition, path, radius, svg, tooltip, width, widthRoot, x, y, zoomIn;

  width = 700;

  height = 700;

  widthRoot = width / 2.63;

  heightRoot = height / 2.63;

  radius = Math.min(width, height) / 2;

  x = d3.scale.linear().range([0, 2 * Math.PI]);

  y = d3.scale.sqrt().range([0, radius]);

  svg = d3.select('svg').attr('width', width).attr('height', height).append('g').attr('transform', 'translate(' + width / 2 + ',' + (height / 2) + ')');

  partition = d3.layout.partition().value(function(d) {
    return Math.abs(Math.round(d.values[0]));
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

  path = null;

  colors = {
    positive: ['#1DC2F7', '#1BB6E8', '#1AAEDE', '#18A2CF', '#1696BF', '#1A8BB3', '#127899', '#136480', '#0E5066', '#0B3C4D'],
    negative: ['#ff747d', '#f5646d', '#ef5761', '#eb4c56', '#df4650', '#d23c46', '#c4343d', '#b72b34', '#a9242d', '#9a1b23'],
    scale: null,
    getColor: function(nb) {
      if (nb < 0) {
        return colors.negative[colors.scale.negative(nb)];
      } else {
        return colors.positive[colors.scale.positive(nb)];
      }
    }
  };

  classes = {
    levels: ['root', 'level-one', 'level-two', 'level-three', 'level-four', 'level-five', 'level-six'],
    getLevel: function(nb) {
      return this.levels[nb];
    },
    getSign: function(nb) {
      if (nb < 0) {
        return 'negative';
      } else {
        return 'positive';
      }
    }
  };

  breadcrumb = {
    el: d3.select('#breadcrumb'),
    create: function(node) {
      return this.el.select('ul').append('li').each(function() {
        d3.select(this).append('span').attr('class', 'breadcrumb--value').style('background', colors.getColor(node.values[0]));
        return d3.select(this).append('h2').attr('class', 'breadcrumb--label').text(node.name);
      }).attr('class', 'visible');
    },
    update: function(path) {
      this.el.select('ul').html('');
      return path.forEach(function(node) {
        return breadcrumb.create(node);
      });
    },
    getAncestors: function(node) {
      var current, steps;
      steps = [];
      current = node;
      while (current.parent) {
        steps.unshift(current.parent);
        current = current.parent;
      }
      console.log(steps);
      return steps;
    }
  };

  tooltip = {
    el: d3.select('.tooltip'),
    width: function() {
      return this.el[0][0].scrollWidth;
    },
    height: function() {
      return this.el[0][0].scrollHeight;
    },
    show: function(d) {
      tooltip.el.transition().duration(300).style('opacity', 1);
      tooltip.el.select('.tooltip--label').text(d.name);
      return tooltip.el.select('.tooltip--value').text(Math.round(d.values[0]).toLocaleString('fr') + ' €').style('color', colors.getColor(d.values[0]));
    },
    update: function() {
      tooltip.el.style('top', d3.event.pageY - (tooltip.height() + 5) + 'px');
      return tooltip.el.style('left', (d3.event.pageX - tooltip.width() / 2) + 'px');
    },
    hide: function() {
      return tooltip.el.transition().duration(300).style('opacity', 1e-6);
    },
    tooltipOver: function() {
      return tooltip.el.style('opacity', 1);
    },
    tooltipOut: function() {
      return tooltip.el.style('opacity', 0);
    }
  };

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

  zoomIn = function(d) {
    breadcrumb.update(breadcrumb.getAncestors(d));
    d3.select('.circle-content').style('display', 'none');
    return path.transition().duration(750).attrTween('d', arcTween(d));
  };

  d3.json('data/example.json', function(error, root) {
    var data, tempValues, values;
    data = root.value;
    values = {
      negative: [],
      positive: []
    };
    tempValues = partition.nodes(data);
    tempValues.forEach(function(d, i) {
      if (d.values[0] < 0) {
        return values.negative.push(d.values[0]);
      } else if (d.values[0] !== 0) {
        return values.positive.push(d.values[0]);
      }
    });
    colors.scale = {
      negative: d3.scale.linear().domain([d3.max(values.negative), d3.min(values.negative)]).rangeRound([0, 9]),
      positive: d3.scale.linear().domain([d3.min(values.positive), d3.max(values.positive)]).rangeRound([0, 9])
    };
    path = svg.selectAll('path').data(partition.nodes(data)).enter().append('g').attr('class', function(d) {
      return classes.getLevel(d.depth);
    }).append('path').attr('data-name', function(d) {
      return d.name;
    }).attr('data-value', function(d) {
      return Math.round(d.values[0]);
    }).attr('class', function(d) {
      return classes.getLevel(d.depth) + ' ' + classes.getSign(d.values[0]);
    }).attr('d', arc).style('fill', function(d) {
      return colors.getColor(d.values[0]);
    }).on('click', zoomIn).on('mouseover', tooltip.show).on('mousemove', tooltip.update).on('mouseout', tooltip.hide).each(function(d) {
      if (d.depth === 0) {
        return d3.select('.root').append('foreignObject').attr('class', 'circle-content').attr('x', widthRoot / 2 * -1).attr('y', widthRoot / 2 * -1).attr('width', widthRoot).attr('height', heightRoot).append('xhtml:div').attr('class', 'circle-text').style('width', widthRoot + 'px').style('height', widthRoot + 'px').append('div').attr('class', 'circle-text--label').each(function(d) {
          d3.select(this).append('h1').attr('class', 'circle-text--label').text(function(d) {
            return d.name;
          });
          return d3.select(this).append('p').attr('class', 'circle-text--value number').text(function(d) {
            return d.value.toLocaleString('fr') + ' €';
          });
        });
      }
    });
  });

  d3.select('.tooltip').on('mouseover', tooltip.tooltipOver).on('mouseleave', tooltip.tooltipOut);

}).call(this);
