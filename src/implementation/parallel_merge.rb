require_relative "threading_extensions"
require_relative "parallel_block_exchange"
require_relative "binary_search"

# Implements a parallel recursive merge using the p-merge algorithm
module ParallelMerge
	include ThreadingExtensions
	include BinarySearch
	include ParallelBlockExchange

	# Implements a parallel recursive merge using threads and the p-merge algorithm.
	# Stop if token indicates program has been cancelled.
	# TODO: Probably refactor a bit.
	def merge(values, upper_start, comparator, cancellation_token)
		return if cancellation_token.cancelled
		return if upper_start == 0 || upper_start == values.length


		upper_median_index = (values.length + upper_start) / 2
		median = values[upper_median_index]
		lower_median_index = binary_search(values[0...upper_start], median, comparator)

		if lower_median_index == upper_start
			upper_start = upper_median_index
		else
			exchange(values[lower_median_index..upper_median_index], upper_start - lower_median_index, cancellation_token)

			# Find the new center - it will have shifted by the difference in size between the upper and lower blocks.
			upper_start +=  (upper_median_index - upper_start + 1) - (upper_start - lower_median_index)
		end

		run_parallel(
			lambda { merge(values[0...upper_start], lower_median_index, comparator, cancellation_token) },
			lambda { merge(values[upper_start...values.length], upper_median_index - upper_start + 1, comparator, cancellation_token) }
		)
	end
end
