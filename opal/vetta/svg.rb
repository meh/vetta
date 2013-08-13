#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class Vetta

class SVG < Engine
	attr_reader :surface

	def initialize(surface)
		@element = create(:svg)

		@element[:width]   = surface.width
		@element[:height]  = surface.height
		@element[:version] = 1.1
		@element[:xmlns]   = 'http://www.w3.org/2000/svg'

		@element.style(overflow: 'hidden')

		@surface = surface
		@surface.element << @element
	end

	def path(options = {}, &block)
		el   = attributes(create(:path), options)
		path = Path.new(&block).to_s

		unless path.start_with?('M') || path.start_with?('m')
			path = 'M 0 0 ' + path
		end

		el[:d] = path

		append(el)
	end

private
	def create(tag)
		$document.create_element(tag, namespace: 'http://www.w3.org/2000/svg')
	end

	def append(el)
		@element << el

		self
	end

	def attributes(el, attrs)
		if fill = attrs[:fill]
			el[:fill] = fill
		else
			el[:fill] = :none
		end

		if stroke = attrs[:stroke]
			el[:stroke] = stroke
		else
			el[:stroke] = '#000'
		end

		el
	end

	class Path
		class Move
			attr_reader :x, :y

			def initialize(*args)
				if args.first.is_a?(Hash)
					@x, @y = args.first[:x], args.first[:y]
				else
					@x, @y = args
				end
			end

			class Absolute < Move
				def to_s
					"M #{x} #{y}"
				end
			end

			class Relative < Move
				def to_s
					"m #{x} #{y}"
				end
			end
		end

		class Line
			attr_reader :x, :y

			def initialize(*args)
				if args.first.is_a?(Hash)
					@x, @y = args.first[:x], args.first[:y]
				else
					@x, @y = args
				end
			end

			class Absolute < Line
				def to_s
					"L #{x} #{y}"
				end
			end

			class Relative < Line
				def to_s
					"l #{x} #{y}"
				end
			end

			class Horizontal
				attr_reader :x

				def initialize(*args)
					if args.first.is_a?(Hash)
						@x = args.first[:x]
					else
						@x, = args
					end
				end

				class Absolute < Horizontal
					def to_s
						"H #{x}"
					end
				end

				class Relative < Horizontal
					def to_s
						"h #{x}"
					end
				end
			end

			class Vertical
				attr_reader :y

				def initialize(*args)
					if args.first.is_a?(Hash)
						@y = args.first[:y]
					else
						@y, = args
					end
				end

				class Absolute < Vertical
					def to_s
						"V #{y}"
					end
				end

				class Relative < Vertical
					def to_s
						"v #{y}"
					end
				end
			end

			class Closed
				def to_s
					"Z"
				end
			end
		end

		module Curve
			class Cubic
				attr_reader :x1, :y1, :x2, :y2, :x, :y

				def initialize(*args)
					if args.first.is_a?(Hash)
						@x1, @y1 = args.first[:x1], args.first[:y1]
						@x2, @y2 = args.first[:x2], args.first[:y2]
						@x,  @y  = args.first[:x], args.first[:y]
					else
						@x1, @y1, @x2, @y2, @x, @y = args
					end
				end

				class Absolute < Cubic
					def to_s
						"C #{x1} #{y1}, #{x2} #{y2}, #{x} #{y}"
					end
				end

				class Relative < Cubic
					def to_s
						"c #{x1} #{y1}, #{x2} #{y2}, #{x} #{y}"
					end
				end

				class Continuation
					attr_reader :x2, :y2, :x, :y

					def initialize(*args)
						if args.first.is_a?(Hash)
							@x2, @y2 = args.first[:x2], args.first[:y2]
							@x,  @y  = args.first[:x], args.first[:y]
						else
							@x2, @y2, @x, @y = args
						end
					end

					class Absolute < Continuation
						def to_s
							"S #{x2} #{y2}, #{x} #{y}"
						end
					end

					class Relative < Continuation
						def to_s
							"s #{x2} #{y2}, #{x} #{y}"
						end
					end
				end
			end

			class Quadratic
				attr_reader :x1, :y1, :x, :y

				def initialize(*args)
					if args.first.is_a?(Hash)
						@x1, @y1 = args.first[:x1], args.first[:y1]
						@x,  @y  = args.first[:x], args.first[:y]
					else
						@x1, @y1, @x, @y = args
					end
				end

				class Absolute < Quadratic
					def to_s
						"Q #{x1} #{y1}, #{x} #{y}"
					end
				end

				class Relative < Quadratic
					def to_s
						"q #{x1} #{y1}, #{x} #{y}"
					end
				end

				class Continuation
					attr_reader :x, :y

					def initialize(*args)
						if args.first.is_a?(Hash)
							@x, @y = args.first[:x], args.first[:y]
						else
							@x, @y = args
						end
					end

					class Absolute < Continuation
						def to_s
							"T #{x} #{y}"
						end
					end

					class Relative < Continuation
						def to_s
							"t #{x} #{y}"
						end
					end
				end
			end

			class Arc
				attr_reader :rx, :ry, :rotation, :x, :y

				def initialize(*args)
					if args.first.is_a?(Hash)
						@rx, @ry  = args.first[:rx], args.first[:ry]
						@x,  @y   = args.first[:x], args.first[:y]
						@rotation = args.first[:rotation] || args.first[:rot]

						@large = args.first[:large]
						@sweep = args.first[:sweep]
					else
						@rx, @ry, @rot, @x, @y = args

						@large = args.last[:large]
						@sweep = args.last[:sweep]
					end
				end

				def large?
					!!@large
				end

				def sweep?
					!!@sweep
				end

				class Absolute < Arc
					def to_s
						"A #{rx} #{ry} #{rotation} #{large? ? 1 : 0} #{sweep? ? 1 : 0} #{x} #{y}"
					end
				end

				class Relative < Arc
					def to_s
						"a #{rx} #{ry} #{rot} #{large? ? 1 : 0} #{sweep? ? 1 : 0} #{x} #{y}"
					end
				end
			end
		end

		def initialize(&block)
			@elements = []

			extend(&block)
		end

		def extend(&block)
			instance_eval(&block)

			self
		end

		def move!(*args)
			@elements << Move::Absolute.new(*args)

			self
		end

		def move(*args)
			@elements << Move::Relative.new(*args)

			self
		end

		def line!(*args)
			@elements << Line::Absolute.new(*args)

			self
		end

		def line(*args)
			@elements << Line::Relative.new(*args)

			self
		end

		def horizontal_line!(*args)
			@elements << Line::Horizontal::Absolute.new(*args)

			self
		end

		def horizontal_line(*args)
			@elements << Line::Horizontal::Relative.new(*args)

			self
		end

		def vertical_line!(*args)
			@elements << Line::Vertical::Absolute.new(*args)

			self
		end

		def vertical_line(*args)
			@elements << Line::Vertical::Relative.new(*args)

			self
		end

		def closed(&block)
			instance_eval(&block) if block

			@elements << Line::Closed.new

			self
		end

		def cubic_curve!(*args)
			@elements << Curve::Cubic::Absolute.new(*args)

			self
		end

		def cubic_curve(*args)
			@elements << Curve::Cubic::Relative.new(*args)

			self
		end

		def quadratic_curve!(*args)
			@elements << Curve::Quadratic::Absolute.new(*args)

			self
		end

		def quadratic_curve(*args)
			@elements << Curve::Quadratic::Relative.new(*args)

			self
		end

		def continue!(*args)
			case @elements.last
			when Curve::Cubic, Curve::Cubic::Continuation
				@elements << Curve::Cubic::Continuation::Absolute.new(*args)

			when Curve::Quadratic, Curve::Quadratic::Continuation
				@elements << Curve::Quadratic::Continuation::Absolute.new(*args)
			end

			self
		end

		def continue(*args)
			case @elements.last
			when Curve::Cubic, Curve::Cubic::Continuation
				@elements << Curve::Cubic::Continuation::Relative.new(*args)

			when Curve::Quadratic, Curve::Quadratic::Continuation
				@elements << Curve::Quadratic::Continuation::Relative.new(*args)
			end

			self
		end

		def arc!(*args)
			Arc::Absolute.new(*args)
		end

		def arc(*args)
			Arc::Relative.new(*args)
		end

		def to_s
			@elements.map(&:to_s).join(" ")
		end

		def to_a
			@elements
		end
	end
end

end
