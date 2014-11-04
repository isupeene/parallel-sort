require_relative 'contracts/contract_decorator'
require_relative 'implementation/parallel_sort_impl'

module ParallelSort
	include ModuleContractDecorator

	def implementation
		ParallelSortImpl
	end
end 
