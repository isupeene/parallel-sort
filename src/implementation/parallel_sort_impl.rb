require_relative "slice"
require_relative "threading_extensions"
require_relative "parallel_merge"
require_relative "../contracts/parallel_sort_contract"

# Implementation of parallel sort
module ParallelSortImpl
	extend ThreadingExtensions
	extend ParallelMerge
	extend ParallelSortContract

	DEFAULT_COMPARATOR = lambda { |x, y| x < y }

	# Sort values using merge sort. Timeout after time_limit. Sorts
	# ascending or descending based on the given comparator or the 
	# default comparator.
	def self.sort(values, time_limit=nil, ascending=true, &comparator)
		comparator ||= DEFAULT_COMPARATOR
		c = ascending ?
			comparator :
			lambda { |x, y| comparator.call(y, x) }

		run_with_time_limit(time_limit) { |cancellation_token|
			sort_impl(Slice.new(values, 0, -1), c, cancellation_token)
		}
	end

	# Sort values using merge sort. Sorts based on given comparator
	# and cancels if token indicates program is cancelling.
	def self.sort_impl(values, comparator, cancellation_token)
		return if cancellation_token.cancelled
		return if values.length < 2

		run_parallel(
			lambda { sort_impl(values[0...(values.length / 2)], comparator, cancellation_token) },
			lambda { sort_impl(values[(values.length / 2)...values.length], comparator, cancellation_token) }
		)
		merge(values, values.length / 2, comparator, cancellation_token)
	end
end
