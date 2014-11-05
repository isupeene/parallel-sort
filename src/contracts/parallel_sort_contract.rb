require 'test/unit'
require_relative 'basic_contracts'

module ParallelSortContract
	extend BasicContracts
	include Test::Unit::Assertions

	DEFAULT_COMPARATOR = lambda { |x, y| x < y }

	def sort_precondition(values, time_limit=nil, ascending=true, &comparator)
		# These preconditions are not comprehensive.
		# We don't check the arity of the indexers.
		comparator ||= DEFAULT_COMPARATOR

		assert(
			values.respond_to?(:[]),
			"Values must be accessible by index."
		)

		assert(
			values.respond_to?(:[]=),
			"Values must be assignable by index."
		)

		if time_limit
			assert(
				time_limit.is_a?(Numeric) &&
				time_limit.real? &&
				time_limit > 0,
				"Time limit must be a real, positive number of seconds."
			)
		end

		values.product(values).each { |x, y|
			assert_nothing_raised(
				"The provided comparator (or <, by default), " \
				"must be applicable to all pairs of values."
			) {
				comparator.call(x, y)
				comparator.call(y, x)
			}
		}
	end

	def sort_postcondition(result, values, time_limit=nil, ascending=true, &comparator)
		comparator ||= DEFAULT_COMPARATOR

		if result
			assert(
				values.each_cons(2).all? { |x, y|
					if ascending
						!comparator.call(y, x) # y is not less than x
					else
						!comparator.call(x, y) # x is not less than y
					end
				},
				"If sort returns true, the results will be sorted."
			)
		end
	end

	def sort_invariant(values, time_limit=nil, ascending=true)
		old_counts = Hash.new(0)
		values.each{ |x| old_counts[x] += 1 }

		start = Time.now

		yield

		stop = Time.now
		if time_limit
			assert(
				stop - start < time_limit + 1,
				"The runtime will not exceed the limit by more than a second."
			)
		end

		new_counts = Hash.new(0)
		values.each{ |x| new_counts[x] += 1 }

		assert_equal(
			old_counts, new_counts,
			"The same elements will be present in the array before and after sorting."
		)
	end
end

