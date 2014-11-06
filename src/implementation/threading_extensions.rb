require_relative "cancellation_token"

# Extra threading related tools
module ThreadingExtensions
	# An error that just wraps another error. Used to bubble up 
	# errors without them being caught.
	class WrappedError < StandardError
		attr_reader :wrapped_error
		
		def initialize(ex)
			@wrapped_error = ex
		end
	end
	
	# Try the passed block. If block fails then retry the number of times
	# that retries specifies. If block still fails on final retry, wrap the 
	# exception that caused the block to fail and raise this wrapped exception
	# so it will bubble up and cancel the program.
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
	
	# Run all blocks in parallel, retrying them 1 time if they fail.
	def run_parallel(*blocks)
		blocks.map{ |b| Thread.new{ retry_n_times(b) } }.each{ |t| t.join }
	end

	# Run block with time limit. If time limit expires then mark token as cancelled
	# to cancel program.
	# Also if block causes a WrappedError exception then cancel the program and raise
	# the exception that was wrapped. (IE: The exception a thread encountered.)
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
