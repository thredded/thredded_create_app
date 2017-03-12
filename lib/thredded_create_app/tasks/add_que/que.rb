Que.logger = proc { ::Rails.logger }
Que.mode = if Rails.env.test?
             :sync
           elsif Rails.env.development? && defined?(Rails::Server)
             :async
           else
             :off
           end
Que.connection = ::ActiveRecord

# Only start up the worker pool if running as a server
Que.mode ||= defined?(::Rails::Server) ? :async : :off

at_exit do
  if Que.mode == :async
    $stdout.puts "Finishing Que's current jobs before exiting..."
    Que.mode = :off
    $stdout.puts "Que's jobs finished, exiting..."
  end
end
