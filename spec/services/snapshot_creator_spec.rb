# frozen_string_literal: true

RSpec.describe Snapshotable::SnapshotCreator do
  let(:record) { double }

  let(:custom_snapshot_attributes) { [] }
  let(:fake_model) do
    {
      id: 1,
      name: 'Jon Snow',
      role: 'King in the North',
      bastard: true,
      father: {
        id: 2,
        name: 'Rhaegar Targaryen'
      },
      mother: {
        id: 3,
        name: 'Lyanna Stark'
      },
      houses: [
        {
          name: 'Stark'
        },
        {
          name: 'Targaryen'
        }
      ]
    }
  end

  before do
    allow(record.class).to receive(:attributes_to_save_on_snapshot).and_return(attributes_to_save_on_snapshot)
    allow(record.class).to receive(:custom_snapshot_attributes).and_return(custom_snapshot_attributes)
    allow(record).to receive(:blank?).and_return(false)
  end

  describe '#call' do
    subject { described_class.new(record).call }

    context 'when only has first-level attributes' do
      let(:attributes_to_save_on_snapshot) { %i[id name] }

      before do
        attributes_to_save_on_snapshot.each do |attribute|
          allow(record).to receive(attribute).and_return(fake_model[attribute])
        end
      end

      it 'returns an object with attributes set' do
        expect(subject).to have_key(:object)
      end

      it 'returns the cache with only the asked parameters' do
        expect(subject[:object].keys).to match_array(attributes_to_save_on_snapshot)
      end

      it 'returns the same parameters as the record' do
        attributes_to_save_on_snapshot.each do |attribute|
          expect(subject[:object][attribute]).to be(fake_model[attribute])
        end
      end
    end

    context 'when has second-level attributes' do
      let(:attributes_to_save_on_snapshot) { [mother: [:name], father: [:id]] }

      before do
        attributes_to_save_on_snapshot.first.each do |association_name, attributes|
          association = fake_model[association_name]

          allow(record).to receive(association_name).and_return(association)
          allow(association).to receive(:blank?).and_return(false)

          attributes.each do |attribute|
            allow(association).to receive(attribute).and_return(association[attribute])
          end
        end
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
            expect(subject["#{association_name}_object"][attribute]).to be(fake_model[association_name][attribute])
          end
        end
      end
    end

    context 'when has second-level attributes with a multiple association' do
      let(:attributes_to_save_on_snapshot) { [houses: [:name]] }

      before do
        attributes_to_save_on_snapshot.first.each do |association_name, attributes|
          multiple_association = fake_model[association_name]

          allow(record).to receive(association_name).and_return(multiple_association)
          allow(multiple_association.class).to receive(:name).and_return('ActiveRecord::Associations::CollectionProxy')

          multiple_association.each do |association|
            allow(association).to receive(:blank?).and_return(false)
            attributes.each do |attribute|
              allow(association).to receive(attribute).and_return(association[attribute])
            end
          end
        end
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
              expect(cache[attribute]).to be(fake_model[association_name][index][attribute])
            end
          end
        end
      end
    end

    context 'when has custom attributes' do
      let(:attributes_to_save_on_snapshot) { [] }
      let(:custom_snapshot_attributes) { [ role_in_kingdom: :role] }

      before do
        allow(record).to receive(:custom_snapshot_attributes).and_return(custom_snapshot_attributes)

        custom_snapshot_attributes.first.each_value do |attribute|
          allow(record).to receive(attribute).and_return(fake_model[attribute])
        end
      end

      it 'returns an object with the custom attribute set' do
        expect(subject.keys).to match_array(custom_snapshot_attributes.first.keys)
      end

      it 'returns the cache with only the asked parameters' do
        expect(subject.keys).to match_array(custom_snapshot_attributes.first.keys)
      end

      it 'returns the same parameters as the record' do
        custom_snapshot_attributes.first.each do |custom_name, attribute|
          expect(subject[custom_name]).to be(fake_model[attribute])
        end
      end
    end
  end
end
