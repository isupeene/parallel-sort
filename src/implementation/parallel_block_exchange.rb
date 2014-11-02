require_relative "threading_extensions"

module ParallelBlockExchange
	include ThreadingExtensions

	def exchange(slice, start_upper, cancellation_token)
		run_parallel(
			lambda { mirror(slice[0...start_upper], cancellation_token) },
			lambda { mirror(slice[start_upper...slice.length], cancellation_token) }
		)
		mirror(slice, cancellation_token)
	end

	def mirror(slice, cancellation_token)
		mirror_impl(slice, 0, slice.length / 2 - 1, cancellation_token)
	end

	def mirror_impl(slice, lower, upper, cancellation_token)
		return if cancellation_token.cancelled
		return if slice.length < 2

		if lower == upper
			slice.swap(lower, -1 - lower)
		else
			split = (lower + upper) / 2
			run_parallel(
				lambda { mirror_impl(slice, lower, split, cancellation_token) },
				lambda { mirror_impl(slice, split + 1, upper, cancellation_token) }
			)
		end
		
	end
end

