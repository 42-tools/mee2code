//= require highcharts
//= require underscore
//= require moment
//= require moment/fr.js

$(function () {
  $('a[href^="#cluster"]').tooltip()

  var charts_data = JSON.parse($('#charts').html());

  $('.charts').highcharts({
    title: {
      text: null
    },
    chart: {
      type: 'area',
      marginBottom: 35,
      style: {
        fontFamily: '"Source Sans Pro", "Helvetica Neue", Helvetica, Arial, sans-serif',
        fontSize: '14px'
      }
    },
    plotOptions: {
      area: {
        stacking: 'normal',
        marker: {
          enabled: false,
          symbol: 'circle',
          radius: 2,
          states: {
            hover: {
              enabled: true
            }
          }
        }
      }
    },
    xAxis: {
      type: 'datetime',
      tickInterval: 3600 * 1000,
      labels: {
        y: 30,
        style: {
          color: '#8f9ea6',
          fontSize: '14px'
        },
        formatter: function () {
            return moment(this.value).format('HH') + 'h';
        }
      },
      lineWidth: 0,
      tickWidth: 0
    },
    yAxis: {
      title: {
        text: null
      },
      labels: {
        enabled: false
      },
      alternateGridColor: '#fafbfc',
      gridLineWidth: 0,
      min: 0,
    },
    tooltip: {
      shared: true,
      useHTML: true,
      formatter: function() {
        var html = '';

        html += '<table>';
        html += '<tr>';
        html += '<td>' + moment(this.x).format('HH') + 'h</td>';
        html += '<td>' + _.reduce(this.points, function(num, el) { return num + el.y; }, 0) + ' étudiants</td>';
        html += '</tr>';

        _.each(this.points, function(el) {
          html += '<tr>';
          html += '<td><span style="color: ' + el.series.color+ '">\u25CF </span>' + el.series.name + ' : </td>';
          html += '<td>' + el.y + ' étudiant(s)</td>';
          html += '</tr>';
        });

        html += '</table></div>';

        return html;
      }
    },
    legend: {
      enabled: false
    },
    credits: {
      enabled: false
    },
    navigation: {
      buttonOptions: {
        enabled: false
      }
    },
    series: charts_data
  })

  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    $chart = $('.charts').highcharts()
    $chart.setSize($('.charts').width(), $chart.chartHeight, doAnimation = false)
  })
})
