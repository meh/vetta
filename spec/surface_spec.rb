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

	describe '#text' do
		it 'draws text' do
			v = Vetta::Surface.new(width: 300, height: 200)

			v.text 'lol' do
				move! x: 0, y: 30
				line  x: 50, y: 50
			end
		end

		it 'draws text along a path' do
			v = Vetta::Surface.new(width: 300, height: 200)
			v.insert($document.body)

			p = v.path stroke: 'red' do
				line x: 10, y: 10
				line x: 50, y: 10
				line x: 60, y: -10
			end

			v.text 'kkkkkkkkkkkkkkkkk', along: p
		end
	end

	describe '#rectangle' do
		it 'draws a rectangle' do
			v = Vetta::Surface.new(width: 300, height: 200)

			v.rectangle x: 10, y: 10, width: 30, height: 40
		end
	end

end
