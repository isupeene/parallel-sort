require_relative "cancellation_token"

module ThreadingExtensions
	class WrappedError < StandardError
		attr_reader :wrapped_error
		
		def initialize(ex)
			@wrapped_error = ex
		end
	end
	
	def retry_n_times(block, retries=1)
		begin
			block.call
		rescue WrappedError => ex
			raise
		rescue => ex
			if (retries -= 1) >= 0
				retry
			else
				raise WrappedError.new(ex)
			end
		end
	end
	
	def run_parallel(*blocks)
		blocks.map{ |b| Thread.new{ retry_n_times(b) } }.each{ |t| t.join }
	end

	def run_with_time_limit(time_limit)
		source = CancellationTokenSource.new

		begin
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
		rescue WrappedError => ex
			puts "Exiting sort due to error in thread."
			source.cancel
			puts "Thread experienced the following error:"
			raise ex.wrapped_error
		end

		return !source.token.cancelled # True if the task finished.
	end
end
