worker_processes Integer(ENV["UNICORN_WORKERS"] || 2)
working_directory "#{ENV['STACK_PATH'] || Rails.root}"
listen "/tmp/web_server.sock", backlog: Integer(ENV['UNICORN_BACKLOG'] || 64)
timeout Integer(ENV['UNICORN_TIMEOUT'] || 30)
pid '/tmp/web_server.pid'
stderr_path "#{ENV['STACK_PATH'] || Rails.root}/log/unicorn.stderr.log"
stdout_path "#{ENV['STACK_PATH'] || Rails.root}/log/unicorn.stdout.log"
preload_app true
check_client_connection false

GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

before_fork do |server, worker|
  old_pid = '/tmp/web_server.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
