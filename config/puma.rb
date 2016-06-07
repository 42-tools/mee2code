app_dir = File.expand_path('..', __dir__)

# The directory to operate out of.
#
# The default is the current directory.
#
directory app_dir

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum, this matches the default thread size of Active Record.
#
threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }.to_i
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
#
port        ENV.fetch('PORT') { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch('RAILS_ENV') { 'development' }

if ENV['RAILS_ENV'].inquiry.production?
  # Store the pid of the server in the file at "path".
  #
  # pidfile '%s/tmp/pids/puma.pid' % [app_dir]

  # Daemonize the server into the background. Highly suggest that
  # this be combined with "pidfile" and "stdout_redirect".
  #
  # The default is "false".
  #
  # daemonize

  # Redirect STDOUT and STDERR to files specified. The 3rd parameter
  # ("append") specifies whether the output is appended, the default is
  # "false".
  #
  # stdout_redirect '%s/log/puma.stdout.log' % [app_dir], '%s/log/puma.stderr.log' % [app_dir], true

  # Specifies the number of `workers` to boot in clustered mode.
  # Workers are forked webserver processes. If using threads and workers together
  # the concurrency of the application would be max `threads` * `workers`.
  # Workers do not work on JRuby or Windows (both of which do not support
  # processes).
  #
  workers ENV.fetch('WEB_CONCURRENCY') { 2 }

  # Use the `preload_app!` method when specifying a `workers` number.
  # This directive tells Puma to first boot the application and load code
  # before forking the application. This takes advantage of Copy On Write
  # process behavior so workers use less memory. If you use this option
  # you need to make sure to reconnect any threads in the `on_worker_boot`
  # block.
  #
  preload_app!

  # The code in the `on_worker_boot` will be called if you are using
  # clustered mode by specifying a number of `workers`. After each worker
  # process is booted this block will be run, if you are using `preload_app!`
  # option you will want to use this block to reconnect to any threads
  # or connections that may have been created at application boot, Ruby
  # cannot share connections between processes.
  #
  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
else
  # Allow puma to be restarted by `rails restart` command.
  plugin :tmp_restart
end
