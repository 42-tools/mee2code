//= require highcharts

$(function () {
  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    $($(this).attr('href')).find('.charts').each(function() {
      $chart = $(this).highcharts()
      $chart.setSize($(this).width(), $chart.chartHeight, doAnimation = false)
    })
  })

  $('a[href^="#cluster"]').tooltip()

  $('.charts').each(function() {
    var charts_data = JSON.parse($('#charts' + $(this).data('cluster')).html());

    $(this).highcharts({
      title: {
        text: null
      },
      chart: {
        marginBottom: 35,
        style: {
          fontFamily: '"Source Sans Pro", "Helvetica Neue", Helvetica, Arial, sans-serif',
          fontSize: '14px'
        }
      },
      xAxis: {
        tickInterval: 1,
        labels: {
          y: 30,
          style: {
            color: '#8f9ea6',
            fontSize: '14px'
          }
        },
        min: 0,
        max: 23,
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
        tickInterval: 10
      },
      tooltip: {
        headerFormat: '',
        pointFormat: '{point.y}',
        valueSuffix: ' étudiant(s)'
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
      series: [{
        name: 'Temperature',
        data: charts_data,
        type: 'spline',
        pointInterval: 1,
        lineColor: '#3aca60',
        lineWidth: 2,
        marker: {
          fillColor: '#ffffff',
          lineWidth: 2,
          lineColor: '#3aca60'
        }
      }]
    })
  })
})