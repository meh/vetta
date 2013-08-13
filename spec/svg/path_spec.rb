require 'spec_helper'

describe Vetta::SVG::Path do
	Path = Vetta::SVG::Path

	describe '#move' do
		it 'creates a relative move with plain parameters' do
			Path.new {
				move 10, 20
			}.to_s.should == 'm 10 20'
		end

		it 'creates a relative move with hash parameters' do
			Path.new {
				move x: 10, y: 20
			}.to_s.should == 'm 10 20'
		end
	end

	describe '#move!' do
		it 'creates an absolute move with plain parameters' do
			Path.new {
				move! 10, 20
			}.to_s.should == 'M 10 20'
		end

		it 'creates an absolute move with hash parameters' do
			Path.new {
				move! x: 10, y: 20
			}.to_s.should == 'M 10 20'
		end
	end

	describe '#line' do
		it 'creates a relative line with plain parameters' do
			Path.new {
				line 10, 20
			}.to_s.should == 'l 10 20'
		end

		it 'creates a relative line with hash parameters' do
			Path.new {
				line x: 10, y: 20
			}.to_s.should == 'l 10 20'
		end
	end

	describe '#line!' do
		it 'creates an absolute line with plain parameters' do
			Path.new {
				line! 10, 20
			}.to_s.should == 'L 10 20'
		end

		it 'creates an absolute line with hash parameters' do
			Path.new {
				line! x: 10, y: 20
			}.to_s.should == 'L 10 20'
		end
	end

	describe '#horizontal_line' do
		it 'creates a relative horizontal line with plain parameters' do
			Path.new {
				horizontal_line 10, 20
			}.to_s.should == 'h 10'
		end

		it 'creates a relative horizontal line with hash parameters' do
			Path.new {
				horizontal_line x: 10, y: 20
			}.to_s.should == 'h 10'
		end
	end

	describe '#horizontal_line!' do
		it 'creates an absolute horizontal line with plain parameters' do
			Path.new {
				horizontal_line! 10, 20
			}.to_s.should == 'H 10'
		end

		it 'creates an absolute horizontal line with hash parameters' do
			Path.new {
				horizontal_line! x: 10, y: 20
			}.to_s.should == 'H 10'
		end
	end

	describe '#vertical_line' do
		it 'creates a relative vertical line with plain parameters' do
			Path.new {
				vertical_line 20
			}.to_s.should == 'v 20'
		end

		it 'creates a relative vertical line with hash parameters' do
			Path.new {
				vertical_line x: 10, y: 20
			}.to_s.should == 'v 20'
		end
	end

	describe '#vertical_line!' do
		it 'creates an absolute vertical line with plain parameters' do
			Path.new {
				vertical_line! 20
			}.to_s.should == 'V 20'
		end

		it 'creates an absolute vertical line with hash parameters' do
			Path.new {
				vertical_line! x: 10, y: 20
			}.to_s.should == 'V 20'
		end
	end

	describe '#closed' do
		it 'closes the wrapped line' do
			Path.new {
				closed {
					move x: 10, y: 10
					line x: 10, y: 10
				}
			}.to_s.should == 'm 10 10 l 10 10 Z'
		end
	end

	describe '#cubic_curve' do
		it 'creates a relative cubic curve with plain parameters' do
			Path.new {
				cubic_curve 10, 20, 30, 40, 50, 60
			}.to_s.should == 'c 10 20, 30 40, 50 60'
		end

		it 'creates a relative cubic curve with hash parameters' do
			Path.new {
				cubic_curve x1: 10, y1: 20, x2: 30, y2: 40, x: 50, y: 60
			}.to_s.should == 'c 10 20, 30 40, 50 60'
		end
	end

	describe '#cubic_curve!' do
		it 'creates an absolute cubic curve with plain parameters' do
			Path.new {
				cubic_curve! 10, 20, 30, 40, 50, 60
			}.to_s.should == 'C 10 20, 30 40, 50 60'
		end

		it 'creates an absolute cubic curve with hash parameters' do
			Path.new {
				cubic_curve! x1: 10, y1: 20, x2: 30, y2: 40, x: 50, y: 60
			}.to_s.should == 'C 10 20, 30 40, 50 60'
		end
	end

	describe '#quadratic_curve' do
		it 'creates a relative quadratic curve with plain parameters' do
			Path.new {
				quadratic_curve 10, 20, 50, 60
			}.to_s.should == 'q 10 20, 50 60'
		end

		it 'creates a relative quadratic curve with hash parameters' do
			Path.new {
				quadratic_curve x1: 10, y1: 20, x: 50, y: 60
			}.to_s.should == 'q 10 20, 50 60'
		end
	end

	describe '#quadratic_curve!' do
		it 'creates an absolute quadratic curve with plain parameters' do
			Path.new {
				quadratic_curve! 10, 20, 50, 60
			}.to_s.should == 'Q 10 20, 50 60'
		end

		it 'creates an absolute quadratic curve with hash parameters' do
			Path.new {
				quadratic_curve! x1: 10, y1: 20, x: 50, y: 60
			}.to_s.should == 'Q 10 20, 50 60'
		end
	end

	describe '#continue' do
		it 'continues a cubic curve' do
			Path.new {
				cubic_curve 10, 20, 30, 40, 50, 60
				continue    70, 80, 90, 100
			}.to_s.should == 'c 10 20, 30 40, 50 60 s 70 80, 90 100'
		end

		it 'continues a cubic curve continuation' do
			Path.new {
				cubic_curve 10, 20, 30, 40, 50, 60
				continue    70, 80, 90, 100
				continue    110, 120, 130, 140
			}.to_s.should == 'c 10 20, 30 40, 50 60 s 70 80, 90 100 s 110 120, 130 140'
		end

		it 'continues a quadratic curve' do
			Path.new {
				quadratic_curve 10, 20, 50, 60
				continue        90, 100
			}.to_s.should == 'q 10 20, 50 60 t 90 100'
		end

		it 'continues a quadratic curve continuation' do
			Path.new {
				quadratic_curve 10, 20, 50, 60
				continue    90, 100
				continue    130, 140
			}.to_s.should == 'q 10 20, 50 60 t 90 100 t 130 140'
		end
	end
end
