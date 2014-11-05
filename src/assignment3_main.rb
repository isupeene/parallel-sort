#
# Group 4 members: Isaac Supeene, Braeden Soetaert
#

# Below are some examples of what our code does. All examples are done with integers but work with all
# objects that define the '<' operator. If a custom comparator is defined then the object need not have
# the '<' operator defined.
#
# To run in the irb interpreter go to the src directory and run the following commands:
# >irb
# >require "./parallel_sort"
# >
gem "test-unit"
require "test/unit"
require "./parallel_sort"

include ParallelSort

# Contracts are enabled by default. To disable them, do the following:
# ModuleContractDecorator.enable_contracts(false)
# And to check if they are currently enabled:
ModuleContractDecorator.enable_contracts?

base = [-6,-4,5,4,1,0,-1,3,4,-5,-3,-2,2,7,6]

# Sorting an array defaults to no timeout, ascending order, and using the '<' operator for comparison	
a = base.clone
sorted_up = [-6,-5,-4,-3,-2,-1,0,1,2,3,4,4,5,6,7]

assert(sort(a), "Sort should succeed.")
assert_equal(sorted_up, a, "Sort should properly sort the array.")

# Demonstrates a sort with a timeout. Timeout in seconds
# If timeout occurs then return value will be false.
a = base.clone
timeout = 1

assert(sort(a,timeout), "Sort should succeed.")
assert_equal(sorted_up, a, "Sort should properly sort the array.")

# Demonstrates a descending sort.
a = base.clone
timeout = 1
ascending = false
sorted_down = [7,6,5,4,4,3,2,1,0,-1,-2,-3,-4,-5,-6]

assert(sort(a,timeout,ascending), "Sort should succeed.")
assert_equal(sorted_down, a, "Sort should properly sort the array.")

# Demonstrates use of a custom comparator
a = base.clone
# Custom comparators return true if y is greater than x and false
# if x is greater than or equal to y.
assert(sort(a){|x,y| x*x < y*y}, "Sort should succeed.")
# Result can vary depending on array if there are equal elements as defined by the comparator
# Result here should be something like [0,-1,1,-2,2,-3,3,-4,4,4,-5,5,-6,6,7] but any of the values
# with the same absolute value could be swapped.
print "#{a}\n"

