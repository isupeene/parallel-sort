# A token that indicates if the process has been cancelled.
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

# Wraps a Cancellation token and can cancel that token.
class CancellationTokenSource
	def initialize
		@token = CancellationToken.new
	end

	attr_reader :token

	# Cancel token so process ends.
	def cancel
		token.send(:cancel)
	end
end
