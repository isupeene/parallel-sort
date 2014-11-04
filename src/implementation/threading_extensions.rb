require_relative "cancellation_token"

module ThreadingExtensions
	def run_parallel(*blocks)
		blocks.map{ |b| Thread.new{ b.call } }.each{ |t| t.join }
	end

	def run_with_time_limit(time_limit)
		source = CancellationTokenSource.new

		if time_limit
			watchdog = Thread.new {
				sleep(time_limit)
				source.cancel
			}
			watchdog.priority = 3 # Top priority
			yield source.token
			watchdog.kill
		else
			yield source.token
		end

		return !source.token.cancelled # True if the task finished.
	end
end
