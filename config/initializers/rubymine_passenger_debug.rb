# frozen_string_literal: true
# generated by RubyMine
debug_port = ENV['RUBYMINE_DEBUG_PORT']

if debug_port
  Rails.logger.info "Preparing to launch debugger for #{$PROCESS_ID}"
  $LOAD_PATH.concat(ENV['RUBYLIB'].split(':'))
  require 'ruby-debug-ide'

  Debugger.cli_debug = ('true' == ENV['RUBYMINE_DEBUG_VERBOSE'])
  @redis_pid = '42' # prevents redis from starting
  @sidekiq_pid = '42' # prevents sidekiq from starting
  Debugger.start_server('127.0.0.1', debug_port.to_i)
end
