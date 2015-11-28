//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree .

(function($, window) {
	$.fn.contextMenu = function (settings) {
		return this.each(function () {
			$(this).on('contextmenu', function (e) {
				var ret;

				if (typeof settings.onPreload !== typeof undefined) {
					ret = settings.onPreload.call(this, settings);		
				}

				if (ret != false) {
					$(settings.selector)
						.data('invokedOn', $(e.target))
						.show()
						.css({
							position: 'absolute',
							left: getLeftLocation(e),
							top: getTopLocation(e)
						})
						.off('click')
						.on('click', function (e) {
							$(this).hide();
					
							var invokedOn = $(this).data('invokedOn');
							var menuItem = $(e.target);
							
							settings.onClick.call(this, $(settings.selector), invokedOn, menuItem);
						});

					if (typeof settings.onPostload !== typeof undefined) {
						settings.onPostload.call(this, $(settings.selector));
					}

					return false;
				} else {
					return false;
				}
			});

			$(document).click(function () {
				$(settings.selector).hide();
			});
		});

		function getLeftLocation(e) {
			var mouseWidth = e.pageX;
			var pageWidth = $(window).width();
			var menuWidth = $(settings.selector).width();

			if (mouseWidth + menuWidth > pageWidth && menuWidth < mouseWidth) {
				return mouseWidth - menuWidth;
			}

			return mouseWidth;
		}		

		function getTopLocation(e) {
			var mouseHeight = e.pageY;
			var pageHeight = $(window).height();
			var menuHeight = $(settings.selector).height();

			if (mouseHeight + menuHeight > pageHeight && menuHeight < mouseHeight) {
				return mouseHeight - menuHeight;
			}

			return mouseHeight;
		}
	};

	$.fn.setDefects = function (status) {
		return this.each(function () {
			if (status == 'success') {
				$(this).children('span').removeClass('text-danger').removeClass('text-warning').removeClass('text-success').addClass('text-success').text('Fonctionnel');
			} else if (status == 'warning') {
				$(this).children('span').removeClass('text-danger').removeClass('text-warning').removeClass('text-success').addClass('text-warning').text('Dysfonctionnel');
			} else if (status == 'danger') {
				$(this).children('span').removeClass('text-danger').removeClass('text-warning').removeClass('text-success').addClass('text-danger').text('Hors service');
			}
		});
	};
})(jQuery, window);

var selectedLocation;

function getDefects(location) {
	var defects = new Object();
	defects['global'] = 0;
	defects['monitor'] = 0;
	defects['keyboard'] = 0;
	defects['mouse'] = 0;

	if ($('#defectsMouse .well p[data-name=mouse-click-left]').children('span').hasClass('text-danger')) {
		defects['mouse'] += 1;
	} else if ($('#defectsMouse .well p[data-name=mouse-click-left]').children('span').hasClass('text-warning')) {
		defects['mouse'] += 2;
	}

	if ($('#defectsMouse .well p[data-name=mouse-click-right]').children('span').hasClass('text-danger')) {
		defects['mouse'] += 4;
	} else if ($('#defectsMouse .well p[data-name=mouse-click-right]').children('span').hasClass('text-warning')) {
		defects['mouse'] += 8;
	}

	if ($('#defectsMouse .well p[data-name=mouse-click-middle]').children('span').hasClass('text-danger')) {
		defects['mouse'] += 16;
	} else if ($('#defectsMouse .well p[data-name=mouse-click-middle]').children('span').hasClass('text-warning')) {
		defects['mouse'] += 32;
	}

	if ($('#defectsMouse .well p[data-name=mouse-scroll-up]').children('span').hasClass('text-danger')) {
		defects['mouse'] += 64;
	} else if ($('#defectsMouse .well p[data-name=mouse-scroll-up]').children('span').hasClass('text-warning')) {
		defects['mouse'] += 128;
	}

	if ($('#defectsMouse .well p[data-name=mouse-scroll-down]').children('span').hasClass('text-danger')) {
		defects['mouse'] += 256;
	} else if ($('#defectsMouse .well p[data-name=mouse-scroll-down]').children('span').hasClass('text-warning')) {
		defects['mouse'] += 512;
	}

	if ($('#defectsMonitor .well p[data-name=monitor-jack]').children('span').hasClass('text-danger')) {
		defects['monitor'] += 1;
	} else if ($('#defectsMonitor .well p[data-name=monitor-jack]').children('span').hasClass('text-warning')) {
		defects['monitor'] += 2;
	}

	if ($('#defectsMonitor .well p[data-name=monitor-usb1]').children('span').hasClass('text-danger')) {
		defects['monitor'] += 4;
	} else if ($('#defectsMonitor .well p[data-name=monitor-usb1]').children('span').hasClass('text-warning')) {
		defects['monitor'] += 8;
	}

	if ($('#defectsMonitor .well p[data-name=monitor-usb2]').children('span').hasClass('text-danger')) {
		defects['monitor'] += 16;
	} else if ($('#defectsMonitor .well p[data-name=monitor-usb2]').children('span').hasClass('text-warning')) {
		defects['monitor'] += 32;
	}

	if ($('#defectsMonitor .well p[data-name=monitor-usb3]').children('span').hasClass('text-danger')) {
		defects['monitor'] += 64;
	} else if ($('#defectsMonitor .well p[data-name=monitor-usb3]').children('span').hasClass('text-warning')) {
		defects['monitor'] += 128;
	}

	if ($('#defectsMonitor .well p[data-name=monitor-usb4]').children('span').hasClass('text-danger')) {
		defects['monitor'] += 256;
	} else if ($('#defectsMonitor .well p[data-name=monitor-usb4]').children('span').hasClass('text-warning')) {
		defects['monitor'] += 512;
	}

	if ($('#defectsMonitor .well p[data-name=monitor-foot]').children('span').hasClass('text-danger')) {
		defects['monitor'] += 1024;
	} else if ($('#defectsMonitor .well p[data-name=monitor-foot]').children('span').hasClass('text-warning')) {
		defects['monitor'] += 2048;
	}

	if ($('#' + location + ' .station > span').hasClass('glyphicon-wrench')) {
		defects['global'] = 2;
	} else if (!$('#' + location + ' .station > span').hasClass('glyphicon-phone')) {
		defects['global'] = 1;
	} else {
		defects['global'] = 0;
	}

	return defects;
}

function setDefects(id, status) {
	if (id == 'defectsMouse') {
		$('#defectsMouse .well p[data-name=mouse-click-left]').setDefects(status);
		$('#defectsMouse .well p[data-name=mouse-click-right]').setDefects(status);
		$('#defectsMouse .well p[data-name=mouse-click-middle]').setDefects(status);
		$('#defectsMouse .well p[data-name=mouse-scroll-up]').setDefects(status);
		$('#defectsMouse .well p[data-name=mouse-scroll-down]').setDefects(status);
	} else if (id == 'defectsMonitor') {
		$('#defectsMonitor .well p[data-name=monitor-jack]').setDefects(status);
		$('#defectsMonitor .well p[data-name=monitor-usb1]').setDefects(status);
		$('#defectsMonitor .well p[data-name=monitor-usb2]').setDefects(status);
		$('#defectsMonitor .well p[data-name=monitor-usb3]').setDefects(status);
		$('#defectsMonitor .well p[data-name=monitor-usb4]').setDefects(status);
		$('#defectsMonitor .well p[data-name=monitor-ethernet]').setDefects(status);
		$('#defectsMonitor .well p[data-name=monitor-foot]').setDefects(status);
	}
}

function hideAlert() {
	$('#myAlert').removeClass('alert-danger').removeClass('alert-warning').removeClass('alert-success').removeClass('hide').addClass('hide').children('span').html('');
}

function showError(msg) {
	$('#myAlert').addClass('alert-danger').removeClass('hide').children('span').html(msg);
}

$(document).disableSelection();
$(function() {
	$('table').popover({
		selector: 'td[data-login] > div',
		trigger: 'hover',
		html: true,
		content: function() {
			var content = '';
			var client = $(this);
			var parent = client.parent();					
			var login = parent.data('login');
			var name = client.data('title');
			var avatar = parent.data('avatar');
			var location = parent.attr('id');
			var last_activity = parent.data('last-activity');
			var month = parent.data('month');
			var years = parent.data('years');

			content += '<div class="station-popover"><figure><img class="img-thumbnail" width="112" height="150" src="' + avatar + '" alt="' + name + '"></figure><div class="info">';
			content += '<p><span>Login</span>: <br />' + login + '</p>';
			content += '<p><span>Location</span>: <br />' + location + '</p>';
			// content += '<p><span>Jabber</span>: <br />';

			// if (client.hasClass('jabber-available') || client.hasClass('jabber-chat'))
			// 	content += 'Disponible';
			// else if (client.hasClass('jabber-dnd'))
			// 	content += 'Occupé';
			// else if (client.hasClass('jabber-away'))
			// 	content += 'Absent';
			// else if (client.hasClass('jabber-xa'))
			// 	content += 'Longue absence';
			// else if (client.hasClass('jabber-unavailable'))
			// 	content += 'Indisponible';
			// else
			// 	content += 'Inconnue';

			// content += '</p>';

			// if (client.hasClass('jabber-dnd') || client.hasClass('jabber-away') || client.hasClass('jabber-xa'))
			// 	content += '<p><span>Dernière activité</span>: <br />' + last_activity + '</p>';

			content += '</div></div>';
			return content;
		}
	});

	$('table td > div[data-contextmenu]').contextMenu({
		onPreload: function (settings) {
			if ($(this).data('contextmenu') == 'default') {
				settings.selector = '#stationContextMenu';
			} else {
				settings.selector = '#' + $(this).data('contextmenu');
			}

			selectedLocation = $(this).parent().attr('id');

			hideAlert();
			$.ajax({
				url: '/ajax/defects/' + selectedLocation,
				dataType: 'json',
				cache: false,
				success: function (response) {
					if (response.defects != null) {
						if (response.defects.mouse & 1) {
							$('#defectsMouse .well p[data-name=mouse-click-left]').setDefects('danger');
						} else if (response.defects.mouse & 2) {
							$('#defectsMouse .well p[data-name=mouse-click-left]').setDefects('warning');
						} else {
							$('#defectsMouse .well p[data-name=mouse-click-left]').setDefects('success');
						}

						if (response.defects.mouse & 4) {
							$('#defectsMouse .well p[data-name=mouse-click-right]').setDefects('danger');
						} else if (response.defects.mouse & 8) {
							$('#defectsMouse .well p[data-name=mouse-click-right]').setDefects('warning');
						} else {
							$('#defectsMouse .well p[data-name=mouse-click-right]').setDefects('success');
						}

						if (response.defects.mouse & 16) {
							$('#defectsMouse .well p[data-name=mouse-click-middle]').setDefects('danger');
						} else if (response.defects.mouse & 32) {
							$('#defectsMouse .well p[data-name=mouse-click-middle]').setDefects('warning');
						} else {
							$('#defectsMouse .well p[data-name=mouse-click-middle]').setDefects('success');
						}

						if (response.defects.mouse & 64) {
							$('#defectsMouse .well p[data-name=mouse-scroll-up]').setDefects('danger');
						} else if (response.defects.mouse & 128) {
							$('#defectsMouse .well p[data-name=mouse-scroll-up]').setDefects('warning');
						} else {
							$('#defectsMouse .well p[data-name=mouse-scroll-up]').setDefects('success');
						}

						if (response.defects.mouse & 256) {
							$('#defectsMouse .well p[data-name=mouse-scroll-down]').setDefects('danger');
						} else if (response.defects.mouse & 512) {
							$('#defectsMouse .well p[data-name=mouse-scroll-down]').setDefects('warning');
						} else {
							$('#defectsMouse .well p[data-name=mouse-scroll-down]').setDefects('success');
						}

						if (response.defects.monitor & 1) {
							$('#defectsMonitor .well p[data-name=monitor-jack]').setDefects('danger');
						} else if (response.defects.monitor & 2) {
							$('#defectsMonitor .well p[data-name=monitor-jack]').setDefects('warning');
						} else {
							$('#defectsMonitor .well p[data-name=monitor-jack]').setDefects('success');
						}

						if (response.defects.monitor & 4) {
							$('#defectsMonitor .well p[data-name=monitor-usb1]').setDefects('danger');
						} else if (response.defects.monitor & 8) {
							$('#defectsMonitor .well p[data-name=monitor-usb1]').setDefects('warning');
						} else {
							$('#defectsMonitor .well p[data-name=monitor-usb1]').setDefects('success');
						}

						if (response.defects.monitor & 16) {
							$('#defectsMonitor .well p[data-name=monitor-usb2]').setDefects('danger');
						} else if (response.defects.monitor & 32) {
							$('#defectsMonitor .well p[data-name=monitor-usb2]').setDefects('warning');
						} else {
							$('#defectsMonitor .well p[data-name=monitor-usb2]').setDefects('success');
						}

						if (response.defects.monitor & 64) {
							$('#defectsMonitor .well p[data-name=monitor-usb3]').setDefects('danger');
						} else if (response.defects.monitor & 128) {
							$('#defectsMonitor .well p[data-name=monitor-usb3]').setDefects('warning');
						} else {
							$('#defectsMonitor .well p[data-name=monitor-usb3]').setDefects('success');
						}

						if (response.defects.monitor & 256) {
							$('#defectsMonitor .well p[data-name=monitor-usb4]').setDefects('danger');
						} else if (response.defects.monitor & 512) {
							$('#defectsMonitor .well p[data-name=monitor-usb4]').setDefects('warning');
						} else {
							$('#defectsMonitor .well p[data-name=monitor-usb4]').setDefects('success');
						}

						if (response.defects.monitor & 1024) {
							$('#defectsMonitor .well p[data-name=monitor-foot]').setDefects('danger');
						} else if (response.defects.monitor & 2048) {
							$('#defectsMonitor .well p[data-name=monitor-foot]').setDefects('warning');
						} else {
							$('#defectsMonitor .well p[data-name=monitor-foot]').setDefects('success');
						}

						if (response.defects.global & 1) {
							$(settings.selector).find('a[data-station=restored]').parent().removeClass('hide');
							$(settings.selector).find('a[data-station=removed]').parent().removeClass('hide').addClass('hide');
							$(settings.selector).find('a[data-station=maintenance]').parent().removeClass('hide').addClass('hide');
							$(settings.selector).find('a[data-target=#defectsModal]').parent().removeClass('hide').addClass('hide');
						} else if (response.defects.global & 2) {
							$(settings.selector).find('a[data-station=restored]').parent().removeClass('hide');
							$(settings.selector).find('a[data-station=removed]').parent().removeClass('hide');
							$(settings.selector).find('a[data-station=maintenance]').parent().removeClass('hide').addClass('hide');
							$(settings.selector).find('a[data-station=broken]').parent().removeClass('hide').addClass('hide');
						} else {
							$(settings.selector).find('a[data-station=restored]').parent().removeClass('hide').addClass('hide');
							$(settings.selector).find('a[data-station=removed]').parent().removeClass('hide');
							$(settings.selector).find('a[data-station=maintenance]').parent().removeClass('hide');
							$(settings.selector).find('a[data-target=#defectsModal]').parent().removeClass('hide');
						}
					} else {
						setDefects('defectsMouse', 'success');
						setDefects('defectsMonitor', 'success');
						$(settings.selector).find('a[data-station=restored]').parent().removeClass('hide').addClass('hide');
						$(settings.selector).find('a[data-station=removed]').parent().removeClass('hide');
						$(settings.selector).find('a[data-station=maintenance]').parent().removeClass('hide');
						$(settings.selector).find('a[data-target=#defectsModal]').parent().removeClass('hide');
					}
				},
				error: function () {
					showError('<span class="glyphicon glyphicon-fire"></span> Une erreur s\'est produite sur le serveur. Veuillez réessayer plus tard.');
				}
			});

			if (!$('#myAlert').hasClass('hide')) {
				return false;
			}
		},
		onClick: function (selector, invokedOn, menuItem) {
			if ($(menuItem).hasClass('glyphicon')) {
				menuItem = $(menuItem).parent();
			} else {
				menuItem = $(menuItem);
			}

			if (typeof $(menuItem).data('station') !== typeof undefined) {
				if ($(invokedOn).hasClass('glyphicon')) {
					invokedOn = $(invokedOn).parent();
				} else {
					invokedOn = $(invokedOn);
				}

				selectedLocation = $(invokedOn).parent().attr('id');

				if (typeof selectedLocation !== typeof undefined) {
					if ($(menuItem).data('station') == 'restored' || $(menuItem).data('station') == 'removed' || $(menuItem).data('station') == 'maintenance') {
						var defects = getDefects(selectedLocation);
						var global = 0;

						if ($(menuItem).data('station') == 'removed') {
							global += 1;
						} else if ($(menuItem).data('station') == 'maintenance') {
							global += 2;
						}

						$.ajax({
							type: 'POST',
							url: '/ajax/defects/' + selectedLocation,
							data: { global: global },
							dataType: 'json',
							cache: false,
							success: function (response) {
								if (global & 1) {
									$('#' + selectedLocation + ' .station').removeClass('text-warning').addClass('text-danger');
									$('#' + selectedLocation + ' .station > span').removeClass('glyphicon-wrench').removeClass('glyphicon-warning-sign').removeClass('glyphicon-phone').addClass('glyphicon-open');
								} else if (global & 2) {
									$('#' + selectedLocation + ' .station').removeClass('text-warning').addClass('text-danger');
									$('#' + selectedLocation + ' .station > span').removeClass('glyphicon-phone').removeClass('glyphicon-warning-sign').removeClass('glyphicon-open').addClass('glyphicon-wrench');
								} else if (defects.monitor > 0 || defects.keyboard > 0 || defects.mouse > 0) {
									$('#' + selectedLocation + ' .station').removeClass('text-danger').removeClass('text-warning').addClass('text-warning');
									$('#' + selectedLocation + ' .station > span').removeClass('glyphicon-wrench').removeClass('glyphicon-warning-sign').removeClass('glyphicon-phone').removeClass('glyphicon-open').addClass('glyphicon-warning-sign');
								} else {
									$('#' + selectedLocation + ' .station').removeClass('text-danger').removeClass('text-warning');
									$('#' + selectedLocation + ' .station > span').removeClass('glyphicon-wrench').removeClass('glyphicon-warning-sign').removeClass('glyphicon-open').addClass('glyphicon-phone');
								}
							},
							error: function () {
								$('#myAlert').addClass('alert-danger').removeClass('hide').children('span').html('<span class="glyphicon glyphicon-fire"></span> Une erreur s\'est produite sur le serveur. Veuillez réessayer plus tard.');
							}
						});
					} else if ($(menuItem).data('station') == 'defects' || $(menuItem).data('station') == 'broken') {
						$('#defectsModal .modal-title').text(selectedLocation);
						$('#defectsModal').modal('show');

						if ($(menuItem).data('station') == 'broken') {
							$('#defectsModal a[href=#defectsBroken]').tab('show');
						} else {
							$('#defectsModal a[href=#defectsMonitor]').tab('show');
						}
					}
				}
			}
		}
	});

	$('#defectsModal a[data-contextmenu]').contextMenu({
		onPreload: function (settings) {
			if ($(this).data('contextmenu') == 'default') {
				settings.selector = '#defectsContextMenu';
			} else {
				settings.selector = '#' + $(this).data('contextmenu');
			}
		},
		onClick: function (selector, invokedOn, menuItem) {
			var span = NaN;

			if (typeof $(menuItem).data('defects') !== typeof undefined) {
				span = $('#defectsModal .well p[data-name=' + $(menuItem).data('defects') + ']');
			} else if (typeof $(invokedOn).data('defects') !== typeof undefined) {
				span = $('#defectsModal .well p[data-name=' + $(invokedOn).data('defects') + ']');
			} else {
				span = $('#defectsModal .well p[data-name=' + $(invokedOn).parent().data('defects') + ']');
			}

			if (span.length > 0) {
				if ($(menuItem).hasClass('text-success')) {
					span.setDefects('success');
				} else if ($(menuItem).hasClass('text-warning')) {
					span.setDefects('warning');
				} else if ($(menuItem).hasClass('text-danger')) {
					span.setDefects('danger');
				}
			}
		},
		onPostload: function () {
			var invokedOn = $(this);

			if (invokedOn.data('contextmenu') == 'default') {
				if (typeof $(this).data('defects') === typeof undefined) {
					invokedOn = $(this).parent();
				}

				$('#defectsContextMenu a.disabled').text($(invokedOn).data('original-title'));
			}
		}
	});

	$('#defectsModal .btn-defects').click(function () {
		var button = $(this);
		var status = button.data('defects');
		var id = button.parent().attr('id');

		setDefects(id, status);
	});

	$('#defectsModal .btn-apply').click(function () {
		var defects = getDefects(selectedLocation);

		$.ajax({
			type: 'POST',
			url: '/ajax/defects/' + selectedLocation,
			data: { monitor: defects.monitor, keyboard: defects.keyboard, mouse: defects.mouse },
			dataType: 'json',
			cache: false,
			success: function (response) {
				if (defects.monitor > 0 || defects.keyboard > 0 || defects.mouse > 0) {
					if (!$('#' + selectedLocation + ' .station').hasClass('text-warning') && !$('#' + selectedLocation + ' .station').hasClass('text-danger')) {
						$('#' + selectedLocation + ' .station').addClass('text-warning');
						$('#' + selectedLocation + ' .station > span').removeClass('glyphicon-phone').addClass('glyphicon-warning-sign');
					}
				} else {
					if ($('#' + selectedLocation + ' .station').hasClass('text-warning')) {
						$('#' + selectedLocation + ' .station').removeClass('text-warning');
						$('#' + selectedLocation + ' .station > span').removeClass('glyphicon-warning-sign').addClass('glyphicon-phone');
					}
				}
			},
			error: function () {
				showError('<span class="glyphicon glyphicon-fire"></span> Une erreur s\'est produite sur le serveur. Veuillez réessayer plus tard.');
			}
		});

		$('#defectsModal').modal('hide');
	});

	$('[data-toggle="tooltip"]').tooltip();
	$('a.notify').click(function () {
		notifyPermission();
		notify('Test', '42 42 42 42');
	});

	$('#login form').submit(function() {
		$('#login_error').removeClass('hide').addClass('hide');
		$('#login input[name=email]').prop('disabled', true);
		$('#login input[name=password]').prop('disabled', true);
		$('#login input[name=remember]').prop('disabled', true);
		$('#login button[type=submit]').button('loading');
		$.ajax({
			url: '/ajax/login',
			type: 'POST',
			dataType: 'json',
			data: {
				login: $('#login input[name=login]').val(),
				password: $('#login input[name=password]').val(),
				remember: $('#login input[name=remember]').val(),
				_: new Date().getTime()
			},
			cache: false,
			success: function(json) {	
				if (json.result == 'success') {
					location.reload();
				} else {
					$('#login_error').removeClass('hide');
					$('#login input[name=login]').prop('disabled', false);
					$('#login input[name=password]').prop('disabled', false);
					$('#login input[name=remember]').prop('disabled', false);
					$('#login button[type=submit]').button('reset');
				}
			}
		});
		return false;
	});
	$('#register form').submit(function() {
		$('#register_error').removeClass('hide').addClass('hide');
		$('#register input[name=login]').prop('disabled', true);
		$('#register button[type=submit]').button('loading');
		$.ajax({
			url: '/ajax/register',
			type: 'POST',
			dataType: 'json',
			data: {
				login: $('#register input[name=login]').val(),
				_: new Date().getTime()
			},
			cache: false,
			success: function(response) {	
				if (response.register == 'OK') {
					location.reload();
				} else {
					$('#register_error').removeClass('hide');
					$('#register input[name=login]').prop('disabled', false);
					$('#register button[type=submit]').button('reset');
				}
			}
		});
		return false;
	});
});

function notifyPermission() {
	if (Notification.permission !== 'granted') {
		Notification.requestPermission();
	}
}

function notify(title, message) {
	if ("Notification" in window) {
		var notification = new Notification(title, {
			icon: window.location.origin + '/42/assets/images/42_logo.png',
			body: message,
		});
	}
}
