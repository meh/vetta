require 'spec_helper'

describe Vetta::Surface do
	DOM = Browser::DOM

	describe '#new' do
		it 'creates the element' do
			v = Vetta::Surface.new(width: 300, height: 200)

			v.element.should be_kind_of DOM::Element
		end

		it 'creates the engine' do
			v = Vetta::Surface.new(width: 300, height: 200)

			v.engine.should be_kind_of Vetta::SVG
		end
	end

	describe '#path' do
		it 'draws a path' do
			v = Vetta::Surface.new(width: 300, height: 200)
			$document.body << v.element

			v.path stroke: 'red' do
				closed {
					line x: 10, y: 10
					line x: 10, y: 10
					line x: 10, y: 10
				}

				move! x: 10, y: 60

				line x: 10, y: 10
				line x: 5,  y: 10
				line x: 0,  y: 10
			end
		end
	end
end
