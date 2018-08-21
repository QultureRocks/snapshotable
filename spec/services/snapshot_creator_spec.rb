# frozen_string_literal: true

RSpec.describe Snapshotable::SnapshotCreator do
  let(:record) { create(:person, name: 'Jon Snow', role: 'King in the North', bastard: true, father: father, mother: mother, houses: [house_stark, house_targaryen]) }
  let(:father) { create(:person, name: 'Rhaegar Targaryen') }
  let(:mother) { create(:person, name: 'Lyanna Stark') }
  let(:house_stark) { create(:house, name: 'Stark') }
  let(:house_targaryen) { create(:house, name: 'Targaryen') }
  let(:record_key) { "#{record.class.name.downcase}_id" }

  let(:custom_snapshot_attributes) { [] }

  before do
    Person.snapshot(*attributes_to_save_on_snapshot)
    Person.custom_snapshot(*custom_snapshot_attributes)
  end

  describe '#call' do
    subject { described_class.new(record).call }

    context 'when only has first-level attributes' do
      let(:attributes_to_save_on_snapshot) { %i[id name] }

      it 'returns an object with attributes set' do
        expect(subject).to have_key(:object)
      end

      it 'returns the cache with only the asked parameters' do
        expect(subject[:object].keys).to match_array(attributes_to_save_on_snapshot)
      end

      it 'returns the same parameters as the record' do
        attributes_to_save_on_snapshot.each do |attribute|
          expect(subject[:object][attribute]).to be(record.send(attribute))
        end
      end

      it 'adds the record_id attribute' do
        expect(subject[record_key]).to eq(record.id)
      end
    end

    context 'when has second-level attributes' do
      let(:attributes_to_save_on_snapshot) { [mother: [:name], father: [:id]] }

      before do
        record.snapshot_foreign_key = nil
      end

      it 'returns an object with relation_object set' do
        expect(subject.keys).to match_array(attributes_to_save_on_snapshot.first.keys.map { |key| "#{key}_object" })
      end

      it 'returns the cache with only the asked parameters' do
        expect(subject.values.map(&:keys)).to match_array(attributes_to_save_on_snapshot.first.values)
      end

      it 'returns the same parameters as the record' do
        attributes_to_save_on_snapshot.first.each do |association_name, attributes|
          attributes.each do |attribute|
            expect(subject["#{association_name}_object"][attribute]).to eq(record.send(association_name).send(attribute))
          end
        end
      end
    end

    context 'when has second-level attributes with a multiple association' do
      let(:attributes_to_save_on_snapshot) { [houses: [:name]] }

      before do
        record.snapshot_foreign_key = nil
      end

      it 'returns an object with record_object set' do
        expect(subject.keys).to match_array(attributes_to_save_on_snapshot.first.keys.map { |key| "#{key}_object" })
      end

      it 'returns the cache with only the asked parameters' do
        expect(subject.values.first.map(&:keys).uniq).to match_array(attributes_to_save_on_snapshot.first.values)
      end

      it 'returns the same parameters as the record' do
        attributes_to_save_on_snapshot.first.each do |association_name, attributes|
          subject["#{association_name}_object"].each_with_index do |cache, index|
            attributes.each do |attribute|
              expect(cache[attribute]).to eq(record.send(association_name)[index].send(attribute))
            end
          end
        end
      end
    end

    context 'when has custom attributes' do
      let(:attributes_to_save_on_snapshot) { [] }
      let(:custom_snapshot_attributes) { [role_in_kingdom: :role] }

      before do
        record.snapshot_foreign_key = nil
      end

      it 'returns an object with the custom attribute set' do
        expect(subject.keys).to match_array(custom_snapshot_attributes.first.keys)
      end

      it 'returns the cache with only the asked parameters' do
        expect(subject.keys).to match_array(custom_snapshot_attributes.first.keys)
      end

      it 'returns the same parameters as the record' do
        custom_snapshot_attributes.first.each do |custom_name, attribute|
          expect(subject[custom_name]).to be(record.send(attribute))
        end
      end
    end
  end
end
