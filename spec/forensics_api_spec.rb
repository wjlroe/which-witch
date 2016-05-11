require 'spec_helper'
require_relative '../lib/forensics_api'

RSpec.describe ForensicsApi, :vcr do
  describe '#fetch_directions'

  describe '#interpret_directions' do
    let(:position) { instance_double("Position") }

    before do
      subject.position = position
    end

    context 'given an empty array of directions' do
      before do
        subject.directions = []
      end

      it "doesn't call position modifying methods" do
        expect(position).not_to receive(:left)
        expect(position).not_to receive(:right)
        expect(position).not_to receive(:forward)

        subject.interpret_directions
      end
    end

    context 'given a directions array with just left' do
      before do
        subject.directions = %w(left)
      end

      it 'only calls the left method' do
        expect(position).to receive(:left)
        expect(position).not_to receive(:right)
        expect(position).not_to receive(:forward)

        subject.interpret_directions
      end
    end

    context 'given a directions array with left, right and forward' do
      before do
        subject.directions = %w(left right forward)
      end

      it 'calls each of the methods on position' do
        expect(position).to receive(:left)
        expect(position).to receive(:right)
        expect(position).to receive(:forward)

        subject.interpret_directions
      end
    end

    context 'given a directions array with an invalid direction' do
      before do
        subject.directions = %w(nope)
      end

      it 'raises an exception' do
        expect {
          subject.interpret_directions
        }.to raise_error(ForensicsApi::InvalidDirection,
                         "nope is not an understood direction")
      end
    end
  end

  describe '#guess_location'
end
