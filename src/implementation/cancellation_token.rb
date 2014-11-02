class CancellationToken
	def initialize
		@cancelled = false
	end

	attr_reader :cancelled

	private
	def cancel
		@cancelled = true
	end
end

class CancellationTokenSource
	def initialize
		@token = CancellationToken.new
	end

	attr_reader :token

	def cancel
		token.send(:cancel)
	end
end
