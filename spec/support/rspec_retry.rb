require 'rspec/retry'
require 'retriable'

##
# Enable specs to mark metadata retry: <count> to retry that given example
# immediately after it fails.
#
# This DOES NOT retry all specs by default.
RSpec.configure do |config|
  ##
  # Print verbose information on when an example is being retried
  # and print the exception that causes a retry
  config.verbose_retry = true
  config.display_try_failure_messages = true

  ##
  # By default, do not retry specs
  config.default_retry_count = 0

  ##
  # Retry JS feature specs, but not during single runs
  if ENV['CI']
    config.around :each, :js do |ex|
      ex.run_with_retry retry: 2
    end
  end
end

##
# Allow specific code blocks to retry on specific errors
Retriable.configure do |c|
  # Three tries in that block
  if ENV['CI']
    c.tries = 3
    c.base_interval = 1
  else
    c.tries = 1
  end
end

##
# Helper to pass options to retriable while logging
# failures
def retry_block(args: {}, &block)
  log_errors = Proc.new do |exception, try, elapsed_time, next_interval|
    $stderr.puts <<-EOS.strip_heredoc
    #{exception.class}: '#{exception.message}'
    #{try} tries in #{elapsed_time} seconds and #{next_interval} seconds until the next try.
    EOS
  end

  Retriable.retriable(args.merge(on_retry: log_errors), &block)
end
