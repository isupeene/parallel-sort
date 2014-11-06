require_relative 'contract_symbols'

# The built-in triple-equals is below the level of ruby 'is_a?'
# We need to redefine it so that instances of our decorator will
# be recognized as instances of the implementation.
class Module
	def ===(x)
		x.is_a?(self)
	end
end

# This module decorates our modules with contracts
module ModuleContractDecorator
	include ContractSymbols

	# Set contracts to be run or not. Default is true
	public
	def self.enable_contracts(bool)
		@@enable_contracts = bool
	end

	# See if contracts are set to run
	def self.enable_contracts?
		@@enable_contracts
	end

	@@enable_contracts = true

	# Boolean determines if contracts are currently being run
	@@evaluating_contracts = false

	# Execute the class invariant if there is one
	def try_execute_class_invariant
		if implementation.respond_to?(:invariant)
			implementation.invariant
		end
	end

	# Execute the method precondition if there is one
	def try_execute_precondition(symbol, *args, &block)
		if implementation.respond_to?(precondition_name(symbol))
			implementation.send(precondition_name(symbol), *args, &block)
		end
	end

	# Execute the method invariant if there is one, otherwise just call the function
	def try_execute_method_invariant(symbol, *args, &block)
		if implementation.respond_to?(invariant_name(symbol))
			result = nil
			implementation.send(invariant_name(symbol), *args) {
				@@evaluating_contracts = false
				result = implementation.send(symbol, *args, &block)
				@@evaluating_contracts = true
			}
			return result
		else
			@@evaluating_contracts = false
			result = implementation.send(symbol, *args, &block)
			@@evaluating_contracts = true
			return result
		end
	end

	# Execute the method postcondition if there is one
	def try_execute_postcondition(symbol, *args, &block)
		if implementation.respond_to?(postcondition_name(symbol))
			implementation.send(postcondition_name(symbol), *args, &block)
		end
	end

	# This method decorates the functions. All methods contained in the implementation
	# will be seen as method_missing so this function will be called and will call
	# the relevant contracts for the method as well as the method if
	# contracts are enabled and contracts are not currently being evaluated. If contracts
	# are not enabled or contracts are already being evaluated then the method will just
	# be called without contracts.
	# Only attempts to call method if it exists in the implementation code.
	def method_missing(symbol, *args, &block)
		super unless implementation.respond_to?(symbol)
		if @@enable_contracts && !@@evaluating_contracts
			begin
				@@evaluating_contracts = true
				symbol = symbol.to_s
				try_execute_class_invariant
				try_execute_precondition(symbol, *args, &block)

				result = try_execute_method_invariant(symbol, *args, &block)

				try_execute_postcondition(symbol, *args.unshift(result), &block)
				try_execute_class_invariant

				return result
			ensure
				@@evaluating_contracts = false
			end
		else
			implementation.send(symbol, *args, &block)
		end
	end
end
