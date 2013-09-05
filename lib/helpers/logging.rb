# encoding: UTF-8

class Transhumance
	module Helpers
		module Logging
	    def with_logging(level = :debug, context = "", &block)
	      logger.send(level.to_sym, "- Starting: #{context}")

	      block.call if block_given?

	      logger.send(level.to_sym, "✓ Completed: #{context}")
	    end
	  end
  end
end
