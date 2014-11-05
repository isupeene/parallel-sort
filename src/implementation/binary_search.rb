module BinarySearch
	def binary_search(values, target, comparator)
		return 0 if values.length == 0
		if values.length == 1
			result = comparator.call(values[0], target) ? 1 : 0
		else
			median_index = values.length / 2 - 1
			median = values[median_index]
			if comparator.call(median, target)
				sub_array = values[median_index + 1, -1]
				return median_index + 1 + binary_search(sub_array, target, comparator)
			else
				sub_array = values[0..median_index]
				return binary_search(sub_array, target, comparator)
			end
		end
	end
end
