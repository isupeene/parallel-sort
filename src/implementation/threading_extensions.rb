module ThreadingExtensions
	def run_parallel(*blocks)
		blocks.map{ |b| Thread.new{ b.call } }.each{ |t| t.join }
	end
end
