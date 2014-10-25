require 'test/unit'
require_relative 'basic_contracts'

module ParallelSortContract
	extend BasicContracts
	include Test::Unit::Assertions

	def sort_precondition(values, time_limit, ascending, &comparator)
		# These preconditions are not comprehensive.
		# We don't check the arity of the indexers.

		assert(
			values.respond_to?(:[]),
			"Values must be accessible by index."
		)

		assert(
			values.respond_to?(:[]=),
			"Values must be assignable by index."
		)

		assert(
			time_limit.is_a?(Numeric) &&
			time_limit.real? &&
			time_limit > 0,
			"Time limit must be a real, positive number of seconds."
		)

		values.product(values).each { |x, y|
			assert_nothing_raised(
				"The provided comparator (or <, by default), " \
				"must be applicable to all pairs of values."
			) {
				comparator(x, y)
				comparator(y, x)
			}
		}
	end

	def sort_postcondition(values, time_limit, ascending, result, &comparator)
		if result
			assert(
				values.each_cons(2).all? { |x, y|
					if ascending
						!comparator(y, x) # y is not less than x
					else
						!comparator(x, y) # x is not less than y
					end
				},
				"If sort returns true, the results will be sorted."
			)
		end
	end

	def sort_invariant(values, time_limit, ascending)
		old_counts = Hash.new(0)
		values.each{ |x| old_counts[x] += 1 }

		start = Time.now

		yield

		stop = Time.now
		assert(
			stop - start < time_limit + 1,
			"The runtime will not exceed the limit by more than a second."
		)

		new_counts = Hash.new(0)
		values.each{ |x| new_counts[x] += 1 }

		assert_equal(
			old_hash, new_hash,
			"The contents of the array will not be modified by sorting."
		)
	end
end

