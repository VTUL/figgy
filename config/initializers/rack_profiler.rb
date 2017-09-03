require 'rack-mini-profiler'
if Rails.env.staging?
  Rails.application.middleware.insert_after(Rack::Deflater, Rack::MiniProfiler)
end
if Rails.env.development?
  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)
end
