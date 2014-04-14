// Generated by CoffeeScript 1.7.1
(function() {
  var arc, arcTween, breadcrumb, chart, classes, colors, height, heightRoot, partition, path, radius, svg, tooltip, width, widthRoot, x, y, zoomIn;

  d3.trigger = function(d3Obj, evtName) {
    var clickEvent, el, event;
    console.log(d3Obj);
    el = d3Obj[0][0];
    event = d3.event;
    if (event.initMouseEvent) {
      clickEvent = document.createEvent('MouseEvent');
      clickEvent.initMouseEvent("click", true, true, window, 0, event.screenX, event.screenY, event.clientX, event.clientY, event.ctrlKey, event.altKey, event.shiftKey, event.metaKey, 0, null);
      return el.dispatchEvent(clickEvent);
    } else {
      if (document.createEventObject) {
        clickEvent = document.createEventObject(window.event);
        clickEvent.button = 1;
        return el.fireEvent(evtName, clickEvent);
      }
    }
  };

  width = 500;

  height = 500;

  widthRoot = width / 2.63;

  heightRoot = height / 2.63;

  radius = Math.min(width, height) / 2;

  x = d3.scale.linear().range([0, 2 * Math.PI]);

  y = d3.scale.sqrt().range([0, radius]);

  chart = {
    highlight: function(d) {
      tooltip.show(d);
      d3.selectAll('path').style('opacity', 0.4);
      return d3.select(this).style('opacity', 1);
    },
    highlightAll: function(s) {
      d3.selectAll('path').on('mouseover', null);
      return d3.selectAll('path').transition().duration(750).style('opacity', 1).each('end', function() {
        return d3.select(this).on('mouseover', chart.highlight);
      });
    }
  };

  svg = d3.select('svg').attr('width', width).attr('height', height).append('g').attr('transform', 'translate(' + width / 2 + ',' + (height / 2) + ')').on('mouseleave', chart.highlightAll);

  partition = d3.layout.partition().value(function(d) {
    return Math.abs(Math.round(d.values[0]));
  }).sort(function(a, b) {
    return d3.ascending(a.name, b.name);
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
    li: d3.select('#breadcrumb li'),
    create: function(node) {
      return this.el.select('ul').append('li').on('click', function() {
        return breadcrumb.navigate(node.code);
      }).each(function() {
        d3.select(this).append('span').attr('class', 'breadcrumb--value').style('background', colors.getColor(node.values[0])).append('div').attr('class', 'reflect');
        return d3.select(this).append('h2').attr('class', 'breadcrumb--label').text(node.name);
      }).attr('class', 'visible').attr('data-depth', node.depth);
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
        steps.unshift(current);
        current = current.parent;
      }
      return steps;
    },
    navigate: function(code) {
      return d3.trigger(d3.select('path[data-code=' + code + ']'), 'click');
    },
    "return": function(node) {
      return d3.trigger(d3.select('path[data-code=' + node.parent.code + ']'), 'click');
    }
  };

  tooltip = {
    el: d3.select('#tooltip'),
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
    }
  };

  arcTween = function(d) {
    var xd, yd, yr;
    xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]);
    yd = d3.interpolate(y.domain(), [d.y, 1]);
    yr = d3.interpolate(y.range(), [0, radius]);
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
    d3.select(this.parentNode).append('foreignObject').attr('class', 'root-circle--content').attr('x', widthRoot / 2 * -1).attr('y', widthRoot / 2 * -1).attr('width', widthRoot).attr('height', heightRoot).append('xhtml:div').attr('class', 'root-circle').style('width', widthRoot + 'px').style('height', widthRoot + 'px').append('div').each(function(d) {
      d3.select(this).append('h1').attr('class', 'root-circle--label').text(function(d) {
        return d.name;
      });
      d3.select(this).append('p').attr('class', 'root-circle--value number').text(function(d) {
        return Math.round(d.values[0]).toLocaleString('fr') + ' €';
      });
      return d3.select(this).append('button').on('click', function() {
        return breadcrumb["return"](d);
      }).attr('class', 'return');
    });
    breadcrumb.update(breadcrumb.getAncestors(d));
    path.transition().duration(750).attrTween('d', arcTween(d));
    d3.select('.root-circle--content').style('opacity', 0).style('display', 'none');
    if (breadcrumb.getAncestors(d).length === 0) {
      d3.select('.root-circle--content').style('opacity', 1).style('display', 'block');
    }
    d3.selectAll('path').style('opacity', '1');
    d3.selectAll('path.' + classes.getLevel(d.depth)).style('opacity', '0');
    return d3.select(this).style('opacity', '1');
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
    }).append('path').attr('data-code', function(d) {
      return d.code;
    }).attr('class', function(d) {
      return classes.getLevel(d.depth) + ' ' + classes.getSign(d.values[0]);
    }).attr('d', arc).style('display', function(d) {
      if (d.values[0] === 0) {
        return 'none';
      }
    }).style('fill', function(d) {
      return colors.getColor(d.values[0]);
    }).style('opacity', function(d) {
      if (d.parent && d.parent.values[0] === d.values[0]) {
        return 1;
      } else {
        return 1;
      }
    }).on('click', zoomIn).on('mouseover', chart.highlight).each(function(d) {
      if (d.depth === 0) {
        return d3.select('.root').append('foreignObject').attr('class', 'root-circle--content').attr('x', widthRoot / 2 * -1).attr('y', widthRoot / 2 * -1).attr('width', widthRoot).attr('height', heightRoot).append('xhtml:div').attr('class', 'root-circle').style('width', widthRoot + 'px').style('height', widthRoot + 'px').append('div').attr('class', 'root-circle--label').each(function(d) {
          d3.select(this).append('h1').attr('class', 'root-circle--label').text(function(d) {
            return d.name;
          });
          d3.select(this).append('p').attr('class', 'root-circle--value number').text(function(d) {
            return Math.round(d.values[0]).toLocaleString('fr') + ' €';
          });
          return tooltip.show(d);
        });
      }
    });
  });

}).call(this);
