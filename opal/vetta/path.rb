class Vetta

class Path
	module Absolute
		def absolute?
			true
		end

		def relative?
			false
		end
	end

	module Relative
		def absolute?
			false
		end

		def relative?
			true
		end
	end

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
			include Path::Absolute
		end

		class Relative < Move
			include Path::Relative
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
			include Path::Absolute
		end

		class Relative < Line
			include Path::Relative
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
				include Path::Absolute
			end

			class Relative < Horizontal
				include Path::Relative
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
				include Path::Absolute
			end

			class Relative < Vertical
				include Path::Relative
			end
		end

		class Closed
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
				include Path::Absolute
			end

			class Relative < Cubic
				include Path::Relative
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
					include Path::Absolute
				end

				class Relative < Continuation
					include Path::Relative
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
				include Path::Absolute
			end

			class Relative < Quadratic
				include Path::Relative
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
					include Path::Absolute
				end

				class Relative < Continuation
					include Path::Relative
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
				include Path::Absolute
			end

			class Relative < Arc
				include Path::Relative
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

	def to_a
		@elements
	end
end

end
