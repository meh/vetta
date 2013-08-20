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
	SVG_NAMESPACE   = 'http://www.w3.org/2000/svg'
	XLINK_NAMESPACE = 'http://www.w3.org/1999/xlink'

	attr_reader :surface

	def initialize(surface)
		@element = create(:svg)

		@element.attributes.merge!({
			width:   surface.width,
			height:  surface.height,
			version: 1.1,
			xmlns:   SVG_NAMESPACE
		})

		@element.style(overflow: 'hidden')

		@surface = surface
		@surface.element << @element

		@defaults = {
			circle: {
				fill:   :none,
				stroke: :black
			},

			rectangle: {
				fill:   :none,
				stroke: :black
			},

			ellipse: {
				fill:  :none,
				stroke: :black
			},

			iamge: {
				preserveAspectRatio: :none
			},

			text: {
				stroke: :none,
				fill:   :black,
				text:   { anchor: :middle }
			},

			path: {
				fill:   :none,
				stroke: :black
			}
		}

		@id = 0
	end

	def clear
		@element.children.each(&:remove)
	end

	def circle(options = {})
		el = init(create(:circle), options, @defaults[:circle])
		el.attributes.merge!({
			cx: options[:x],
			cy: options[:y],
			r:  options[:r] || options[:radius]
		})

		append(el)
	end

	def rectangle(options = {})
		el = init(create(:rect), options, @defaults[:rectangle])
		el.attributes.merge!({
			x:      options[:x],
			y:      options[:y],
			width:  options[:w] || options[:width],
			height: options[:h] || options[:height],
			r:      options[:r] || options[:radius] || 0,
			rx:     options[:r] || options[:radius] || 0,
			ry:     options[:r] || options[:radius] || 0
		})

		append(el)
	end

	def ellipse(options = {})
		el = init(create(:ellipse), options, @defaults[:rectangle])
		el.attributes.merge!({
			x:  options[:x],
			y:  options[:y],
			rx: (options[:r] || options[:radius])[:x],
			ry: (options[:r] || options[:radius])[:y]
		})

		append(el)
	end

	def image(source, options = {}, &block)
		el = init(create(:image), options, @defaults[:image])
		el.attributes.merge!({
			x:      options[:x],
			y:      options[:y],
			width:  options[:w] || options[:width],
			height: options[:h] || options[:height]
		})

		el.set(:src, source)
		el.set('xlink:href', source, namespace: XLINK_NAMESPACE)

		append(el)
	end

	def text(content, options = {}, &block)
		if block
			path = init(create(:path), options, @defaults[:path])
			path.attributes.merge!({
				id: new_id,
				d:  path_for(&block)
			})

			definitions << path

			options[:along] = path
		end

		if path = options[:along]
			txt = create(:text)
			txp = create(:textPath)

			txp.set('xlink:href', "##{path[:id]}", namespace: XLINK_NAMESPACE)
			txp.text = content

			append(txt << txp)
		else
			txt      = init(create(:text), options, @defaults[:text])
			txt.text = content

			append(txt)
		end
	end

	def path(options = {}, &block)
		path = init(create(:path), options, @defaults[:path])
		path[:d] = path_for(&block)

		append(path)
	end

private
	def definitions
		return @defs if @defs

		@defs = create(:defs)
		@element << @defs

		@defs
	end

	def new_id
		"x#{@id += 1}"
	end

	def create(tag)
		$document.create_element(tag, namespace: SVG_NAMESPACE)
	end

	def append(el)
		@element << el

		el
	end

	def init(el, attrs, defaults = {})
		el[:id] = new_id

		case fill = attrs.delete(:fill) || defaults[:fill]
		when Hash
			if color = fill[:color]
				el[:fill] = color
			end

			if opacity = fill[:opacity]
				el['fill-opacity'] = opacity
			end

		when String
			el[:fill] = fill
		end

		case stroke = attrs.delete(:stroke) || defaults[:stroke]
		when Hash
			if color = stroke[:color]
				el[:stroke] = color
			end

			if width = stroke[:width]
				el['stroke-width'] = width
			end

			if (line = stroke[:line]).is_a?(Hash)
				if cap = line[:cap]
					el['stroke-linecap'] = cap
				end

				if join = line[:join]
					el['stroke-linejoin'] = join
				end
			end

		when String
			el[:stroke] = stroke
		end

		el.style(attrs)

		el
	end

	def path_for(&block)
		path = Path.new(&block).to_s

		unless path.start_with?('M') || path.start_with?('m')
			path = 'M 0 0 ' + path
		end

		path
	end

	class Path < Path
		# TODO: remove these
		Move  = Vetta::Path::Move
		Line  = Vetta::Path::Line
		Curve = Vetta::Path::Curve

		def to_s
			to_a.map {|e|
				case e
				when Move
					"#{e.absolute? ? ?M : ?m} #{e.x} #{e.y}"

				when Line
					"#{e.absolute? ? ?L : ?l} #{e.x} #{e.y}"

				when Line::Horizontal
					"#{e.absolute? ? ?H : ?h} #{e.x}"

				when Line::Vertical
					"#{e.absolute? ? ?V : ?v} #{e.y}"

				when Line::Closed
					"Z"

				when Curve::Cubic
					"#{e.absolute? ? ?C : ?c} #{e.x1} #{e.y1}, #{e.x2} #{e.y2}, #{e.x} #{e.y}"

				when Curve::Cubic::Continuation
					"#{e.absolute? ? ?S : ?s} #{e.x2} #{e.y2}, #{e.x} #{e.y}"

				when Curve::Quadratic
					"#{e.absolute? ? ?Q : ?q} #{e.x1} #{e.y1}, #{e.x} #{e.y}"

				when Curve::Quadratic::Continuation
					"#{e.absolute? ? ?T : ?t} #{e.x} #{e.y}"

				when Curve::Arc
					"#{e.absolute? ? ?A : ?a} #{e.rx} #{e.ry} #{e.rotation} #{e.large? ? 1 : 0} #{e.sweep? ? 1 : 0} #{e.x} #{e.y}"

				end
			}.join(' ')
		end
	end
end

end
