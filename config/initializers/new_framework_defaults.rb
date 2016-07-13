# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 5.0 upgrade.
#
# Once upgraded flip defaults one by one to migrate to the new default.
#
# Read the Rails 5.0 release notes for more info on each option.

# Enable per-form CSRF tokens. Previous versions had false.
Rails.application.config.action_controller.per_form_csrf_tokens = true

# Enable origin-checking CSRF mitigation. Previous versions had false.
Rails.application.config.action_controller.forgery_protection_origin_check = true

# Preserve the timezone of the receiver when calling to `to_time`.
# Ruby 2.4 will change the behavior of `to_time` to preserve the timezone
# when converting to an instance of `Time` instead of the previous behavior
# of converting to the local system timezone.
#
# Rails 5.0 introduced this config option so that apps made with earlier
# versions of Rails are not affected when upgrading.
# Previous versions had false.
ActiveSupport.to_time_preserves_timezone = true

# Require `belongs_to` associations by default. Previous versions had false.
# default, so it is introduced as a configuration option to ensure that apps
# made on earlier versions of Rails are not affected when upgrading.
Rails.application.config.active_record.belongs_to_required_by_default = false

# Do not halt callback chains when a callback returns false. Previous versions had true.
# Rails 5.0 default, so it is introduced as a configuration option to ensure
# that apps made with earlier versions of Rails are not affected when upgrading.
ActiveSupport.halt_callback_chains_on_return_false = false
