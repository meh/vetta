#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'forwardable'

class Vetta

class Surface
	extend Forwardable

	attr_reader :element, :engine
	attr_reader :x, :y, :width, :height
	def_delegators :@engine, :path, :circle, :rectangle, :ellipse, :image, :text, :size=

	def initialize(*args)
		@element = case args.first
			when DOM::Element
				args.shift

			when String
				$document[args.shift]

			else
				$document.create_element 'div'
		end

		options = args.shift

		if options[:x] || options[:y]
			@x, @y = options[:x] || 0, options[:y] || 0

			@element.style(top: "#{@y}px", left: "#{@x}px")
		else
			@x, @y = @element.position.to_a
		end

		if options[:width] && options[:height]
			@width, @height = options[:width], options[:height]

			@element.style(width: "#{@width}px", height: "#{@width}px")
		else
			@width, @height = @element.size.to_a
		end

		@engine = case options[:engine]
			when nil, :svg
				SVG.new(self)

			else
				raise NotImplementedError
		end
	end
end

end
