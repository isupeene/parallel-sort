require_relative "overload_table"

# Provides slices of a single array for in place sorting of an array.
# Each slice accesses an underlying array but only gives access to the set range
# of indices that are defined in the constructor.
# NOTE: We can do some minor optimizations by circumventing overload
# resolution when accessing methods from within the class.
class Slice
	include Enumerable

	# Return range shifted by value
	private
	def shift_range(range, value)
		return range if range.min.nil?
		range.min+value..range.max+value
	end

	# Get index in slice of given value
	def extract_single_index(value, length)
		value.is_a?(Integer) && value < 0 ?
			length + value :
			value
	end

	# Get range of elements in slice.
	def extract_two_indices(i, j, length)
		i = extract_single_index(i, length)
		j >= 0 ?
			i...i+j :
			i..length+j
	end

	# Convert indices to a range or index
	def extract_indices(*indices, length)
		indices.length == 1 ?
			extract_single_index(*indices, length) :
			extract_two_indices(*indices, length)
	end

	##################
	# Initialization #
	##################

	# Set up slice with full array but only able to access the range of the array specified.
	public
	def initialize(array, *indices)
		@array = array
		range = extract_indices(*indices, @array.length)
		@start, @end = range.min, range.max
	end

	##########
	# Access #
	##########

	# Get new slice out of current slice by range.
	private
	def access_by_range(range)
		Slice.new(@array, shift_range(range, @start))
	end

	# Get value from array based on index in slice
	def access_by_index(index)
		@array[index + @start]
	end

	@@access_table = OverloadTable.new({
		Integer => :access_by_index,
		Range => :access_by_range
	})

	# Get value or slice out of slice
	def access(range_or_index)
		send(@@access_table.select(range_or_index), range_or_index)
	end

	# Get value or slice out of slice
	public
	def [](*indices)
		access(extract_indices(*indices, length))
	end

	############
	# Mutation #
	############

	# Change slice so the range of indices is equal to the array.
	private
	def mutation_by_range(range, array)
		array.each_with_index{ |x, i| self[range.min + i] = x }
	end

	# Change value in array based on index into slice.
	def mutation_by_index(index, value)
		@array[@start + index] = value
	end

	@@mutation_table = OverloadTable.new({
		Integer => :mutation_by_index,
		Range => :access_by_range
	})

	# Alter array based on index/range in slice.
	def mutate(range_or_index, value)
		send(@@mutation_table.select(range_or_index), range_or_index, value)
	end

	# Alter array based on index/range in slice.
	public
	def []=(*indices, value)
		mutate(extract_indices(*indices, length), value)
	end

	##########
	# Length #
	##########

	# Length of slice
	def length
		return 0 if @start.nil?
		@end - @start + 1
	end

	alias size length

	#############
	# Iteration #
	#############

	# Return each element in slice
	def each
		return to_enum(:each) unless block_given?
		each_with_index{ |x, i| yield x }
	end

	# Return each element in slice with its index in the slice.
	def each_with_index
		return to_enum(:each_with_index) unless block_given?
		length.times{ |i| yield self[i], i }
	end

	#############
	# Functions #
	#############

	# Swap elements at indices i and j in the slice.
	def swap(i, j)
		temp = self[i]
		self[i] = self[j]
		self[j] = temp
	end

	#########################
	# String Representation #
	#########################

	def to_s
		return "[]" if @start.nil?
		@array[@start..@end]
	end

	def inspect
		to_s
	end
end

