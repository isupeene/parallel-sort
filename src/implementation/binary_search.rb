module BinarySearch
	# TODO
	def binary_search(values, target, comparator)
		values.find_index{ |x| !comparator.call(x, target) } || values.length
	end
end
