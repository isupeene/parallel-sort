require_relative "threading_extensions"

# Exchange blocks in parallel to sort a slice of array elements. Done with recursive threads.
module ParallelBlockExchange
	include ThreadingExtensions

	# Exchanges the block of elements in the slice below start_upper with the block of elements at and above start_upper.
	def exchange(slice, start_upper, cancellation_token)
		run_parallel(
			lambda { mirror(slice[0...start_upper], cancellation_token) },
			lambda { mirror(slice[start_upper...slice.length], cancellation_token) }
		)
		mirror(slice, cancellation_token)
	end

	# Reverses the elements in the slice.
	def mirror(slice, cancellation_token)
		mirror_impl(slice, 0, slice.length / 2 - 1, cancellation_token)
	end

	# Reverses the elements in the slice using recursive parallel threads.
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

