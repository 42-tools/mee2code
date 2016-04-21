$(function() {
  $('.destroy-friend').on('ajax:success', function(event, data, status, xhr) {
    $(this).parents('tr').remove();

    if ($('.table-friend tbody tr').length === 1) $('.table-friend tbody tr:first').removeClass('hide')
  }).on('ajax:error', function(event, xhr, status, error) {
    // TODO - add error handling
  });
});
