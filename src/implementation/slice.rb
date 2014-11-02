require_relative "overload_table"

# NOTE: We can do some minor optimizations by circumventing overload
# resolution when accessing methods from within the class.
class Slice
	include Enumerable

	private
	def shift_range(range, value)
		return range if range.min.nil?
		range.min+value..range.max+value
	end

	def extract_single_index(value, length)
		value.is_a?(Integer) && value < 0 ?
			length + value :
			value
	end

	def extract_two_indices(i, j, length)
		i = extract_single_index(i, length)
		j >= 0 ?
			i...i+j :
			i..length+j
	end

	def extract_indices(*indices, length)
		indices.length == 1 ?
			extract_single_index(*indices, length) :
			extract_two_indices(*indices, length)
	end

	##################
	# Initialization #
	##################

	public
	def initialize(array, *indices)
		@array = array
		range = extract_indices(*indices, @array.length)
		@start, @end = range.min, range.max
	end

	##########
	# Access #
	##########

	private
	def access_by_range(range)
		Slice.new(@array, shift_range(range, @start))
	end

	def access_by_index(index)
		@array[index + @start]
	end

	@@access_table = OverloadTable.new({
		Integer => :access_by_index,
		Range => :access_by_range
	})

	def access(range_or_index)
		send(@@access_table.select(range_or_index), range_or_index)
	end

	public
	def [](*indices)
		access(extract_indices(*indices, length))
	end

	############
	# Mutation #
	############

	private
	def mutation_by_range(range, array)
		array.each_with_index{ |x, i| self[range.min + i] = x }
	end

	def mutation_by_index(index, value)
		@array[@start + index] = value
	end

	@@mutation_table = OverloadTable.new({
		Integer => :mutation_by_index,
		Range => :access_by_range
	})

	def mutate(range_or_index, value)
		send(@@mutation_table.select(range_or_index), range_or_index, value)
	end

	public
	def []=(*indices, value)
		mutate(extract_indices(*indices, length), value)
	end

	##########
	# Length #
	##########

	def length
		return 0 if @start.nil?
		@end - @start + 1
	end

	alias size length

	#############
	# Iteration #
	#############

	def each
		return to_enum(:each) unless block_given?
		each_with_index{ |x, i| yield x }
	end

	def each_with_index
		return to_enum(:each_with_index) unless block_given?
		length.times{ |i| yield self[i], i }
	end

	#############
	# Functions #
	#############

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

