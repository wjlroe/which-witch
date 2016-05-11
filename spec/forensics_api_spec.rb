require 'spec_helper'
require_relative '../lib/forensics_api'

RSpec.describe ForensicsApi do
  let(:email) { 'test-user@example.com' }

  subject { described_class.new(email) }

  before do
    subject.host = 'http://www.example.com'
  end

  describe '#fetch_directions' do
    it 'includes /api/ path' do
      request = stub_request(:get, %r{.*example.com/api/.*}).
                to_return(body: File.read(file_fixture('directions.json')),
                          status: 200)

      subject.fetch_directions

      expect(request).to have_been_requested
    end

    it 'includes email in the path' do
      request = stub_request(:get,
                             %r{.*example.com.*/test-user@example.com/.*}).
                to_return(body: File.read(file_fixture('directions.json')),
                          status: 200)

      subject.fetch_directions

      expect(request).to have_been_requested
    end

    it 'calls the directions API' do
      request = stub_request(:get, %r{.*example.com.*/directions}).
                to_return(body: File.read(file_fixture('directions.json')),
                          status: 200)

      subject.fetch_directions

      expect(request).to have_been_requested
    end

    it 'saves the array of directions' do
      stub_request(:get, %r{.*example.com.*/directions}).
        to_return(body: File.read(file_fixture('directions.json')), status: 200)

      subject.fetch_directions

      # rubocop:disable Style/WordArray
      expected = ['forward',
                  'right',
                  'forward',
                  'forward',
                  'forward',
                  'left',
                  'forward',
                  'forward',
                  'left',
                  'right',
                  'forward',
                  'right',
                  'forward',
                  'forward',
                  'right',
                  'forward',
                  'forward',
                  'left']
      # rubocop:enable Style/WordArray

      expect(subject.directions).to eq(expected)
    end
  end

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

  describe '#guess_location' do
    let(:position) { instance_double("Position") }

    before do
      subject.position = position
      subject.directions = []
    end

    context 'correct location' do
      let(:response) { File.read(file_fixture('success.json')) }
    end

    context 'incorrect location' do
      let(:response) { File.read(file_fixture('failure.json')) }

      before do
        allow(position).to receive(:x).and_return(0)
        allow(position).to receive(:y).and_return(0)
      end

      it 'calls the location API' do
        request = stub_request(:get, %r{.*www.example.com.*/location/0/0}).
                  and_return(body: response)

        subject.guess_location

        expect(request).to have_been_requested
      end

      it 'includes the email address' do
        request = stub_request(
          :get,
          %r{.*www.example.com.*/test-user@example.com/.*}
        ).and_return(body: response)

        subject.guess_location

        expect(request).to have_been_requested
      end

      it 'includes the /api/ path' do
        request = stub_request(:get,
                               %r{.*www.example.com/api/.*}).
                  and_return(body: response)

        subject.guess_location

        expect(request).to have_been_requested
      end

      it 'reports the failure message' do
        stub_request(:get,
                     %r{.*www.example.com/.*/location/.*}).
          and_return(body: response)

        expect(subject.guess_location).to match(/failed to recover/)
      end
    end
  end

  describe '#search' do
    context 'correct guess once' do
      it 'reports successful recovery' do
        stub_request(:get, %r{.*example.com.*/directions}).
          to_return(body: File.read(file_fixture('directions.json')))
        stub_request(:get, %r{.*www.example.com.*/location/.*}).
          and_return(body: File.read(file_fixture('success.json')))

        expect(subject.search).to match(/successfully recovered/)
      end
    end

    context 'correct guess twice' do
      it "lets us know we've already succeeded" do
        stub_request(:get, %r{.*example.com.*/directions}).
          to_return(body: File.read(file_fixture('directions.json')))
        stub_request(:get, %r{.*www.example.com.*/location/.*}).
          to_return(body: File.read(file_fixture('success.json'))).then.
          to_return(body: File.read(file_fixture('already_recovered.json')))

        subject.search
        subject.guess_location

        expect(subject.report).to match(/already recovered/)
      end
    end

    context 'incorrect directions' do
      it 'reports failure' do
        stub_request(:get, %r{.*example.com.*/directions}).
          to_return(body: File.read(file_fixture('incorrect_directions.json')))
        stub_request(:get, %r{.*www.example.com.*/location/.*}).
          and_return(body: File.read(file_fixture('failure.json')))

        expect(subject.search).to match(/failed to recover/)
      end
    end
  end

  describe '#guess_coordinates' do
    it 'formats the location of the guessed location as coordinates' do
      stub_request(:get, %r{.*example.com.*/directions}).
        to_return(body: File.read(file_fixture('directions.json')))
      stub_request(:get, %r{.*www.example.com.*/location/.*}).
        and_return(body: File.read(file_fixture('success.json')))

      subject.search

      expect(subject.guess_coordinates).to eq("(5,2)")
    end
  end
end
