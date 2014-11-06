require_relative 'contracts/contract_decorator'
require_relative 'implementation/parallel_sort_impl'

# Class to decorate the parallel sort implementation and add contracts to it.
module ParallelSort
	include ModuleContractDecorator

	def implementation
		ParallelSortImpl
	end
end 
