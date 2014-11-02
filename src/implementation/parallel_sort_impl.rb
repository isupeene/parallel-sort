require_relative "../slice"
require_relative "../threading_extensions"
require_relative "../parallel_merge"
require_relative "../cancellation_token" # TODO: Probably delegate to threading extensions

module ParallelSortImpl
	include ThreadingExtensions
	include ParallelMerge

	DEFAULT_COMPARATOR = lambda { |x, y| x < y }

	def sort(values, ascending=true, &comparator)
		comparator ||= DEFAULT_COMPARATOR
		c = ascending ?
			comparator :
			lambda { |x, y| comparator.call(y, x) }

		source = CancellationTokenSource.new
		sort_impl(Slice.new(values, 0, -1), c, source.token)
	end

	def sort_impl(values, comparator, cancellation_token)
		return if cancellation_token.cancelled
		return if values.length < 2

		run_parallel(
			lambda { sort_impl(values[0...values.length / 2], comparator, cancellation_token) },
			lambda { sort_impl(values[values.length / 2...values.length], comparator, cancellation_token) }
		)
		merge(values, values.length / 2, comparator, cancellation_token)
	end
end
