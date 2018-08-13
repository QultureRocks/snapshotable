# frozen_string_literal: true

require_relative 'helpers/test_model'

RSpec.describe Snapshotable::Model do
  let(:test_class) { TestModel }
  let(:record) { test_class.new }

  describe 'adding methods' do
    context 'class' do
      it 'adds snapshot method' do
        expect(test_class).to respond_to(:snapshot)
      end

      it 'adds snapshot_ignore_diff method' do
        expect(test_class).to respond_to(:snapshot_ignore_diff)
      end

      it 'adds custom_snapshot method' do
        expect(test_class).to respond_to(:custom_snapshot)
      end
    end

    context 'instance' do
      it 'adds take_snapshot! method' do
        expect(record).to respond_to(:take_snapshot!)
      end

      it 'adds snapshots method' do
        expect(record).to respond_to(:snapshots)
      end

      it 'adds snapshot_class method' do
        expect(record).to respond_to(:snapshot_class)
      end

      it 'adds should_create_new_snapshot? method' do
        expect(record).to respond_to(:should_create_new_snapshot?)
      end
    end
  end
end
