require 'spec_helper'
require_relative '../lib/position'

RSpec.describe Position do
  describe '#direction' do
    it 'defaults to north' do
      expect(subject.direction).to eq(:north)
    end
  end

  describe '#x' do
    it 'defaults to 0' do
      expect(subject.x).to eq(0)
    end
  end

  describe '#y' do
    it 'defaults to 0' do
      expect(subject.y).to eq(0)
    end
  end

  describe '#right' do
    it 'rotates once to east' do
      subject.right

      expect(subject.direction).to eq(:east)
    end

    it 'rotates twice to south' do
      2.times do
        subject.right
      end

      expect(subject.direction).to eq(:south)
    end

    it 'rotates three times to west' do
      3.times do
        subject.right
      end

      expect(subject.direction).to eq(:west)
    end

    it 'rotates four times back to north' do
      expect {
        4.times do
          subject.right
        end
      }.not_to change { subject.direction }
    end
  end

  describe '#left' do
    it 'rotates once to west' do
      subject.left

      expect(subject.direction).to eq(:west)
    end

    it 'rotates twice to south' do
      2.times do
        subject.left
      end

      expect(subject.direction).to eq(:south)
    end

    it 'rotates three times to east' do
      3.times do
        subject.left
      end

      expect(subject.direction).to eq(:east)
    end

    it 'rotates four times back to north' do
      4.times do
        subject.left
      end

      expect(subject.direction).to eq(:north)
    end
  end

  it 'will be facing north after changing direction twice' do
    subject.left
    subject.right

    expect(subject.direction).to eq(:north)
  end

  describe '#forward' do
    def self.forward_doesnt_change_direction
      it "doesn't change the direction" do
        expect {
          subject.forward
        }.not_to change { subject.direction }
      end
    end

    def self.forward_doesnt_change(coordinate)
      it "doesn't change the #{coordinate} coordinate" do
        expect {
          subject.forward
        }.not_to change { subject.public_send(coordinate) }
      end
    end

    def self.change_coordinate(coordinate, by_num)
      word = by_num == 1 ? 'increases' : 'decreases'
      it "#{word} the #{coordinate} coordinate" do
        expect {
          subject.forward
        }.to change { subject.public_send(coordinate) }.by(by_num)
      end
    end

    def self.forward_increases(coordinate)
      change_coordinate(coordinate, 1)
    end

    def self.forward_decreases(coordinate)
      change_coordinate(coordinate, -1)
    end

    context 'facing north' do
      forward_doesnt_change(:x)
      forward_increases(:y)
      forward_doesnt_change_direction
    end

    context 'facing east' do
      before do
        subject.right
      end

      forward_increases(:x)
      forward_doesnt_change(:y)
      forward_doesnt_change_direction
    end

    context 'facing south' do
      before do
        2.times do
          subject.right
        end
      end

      forward_doesnt_change(:x)
      forward_decreases(:y)
      forward_doesnt_change_direction
    end

    context 'facing west' do
      before do
        subject.left
      end

      forward_decreases(:x)
      forward_doesnt_change(:y)
      forward_doesnt_change_direction
    end
  end
end
