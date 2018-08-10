RSpec.describe CacheableModels::CacheAttributes do
  let(:record) { double }

  let(:fake_model) {
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
  }


  before do
    allow(record).to receive(:attributes_to_cache).and_return(attributes_to_cache)
    allow(record).to receive(:blank?).and_return(false)
  end

  describe '#call' do
    subject { described_class.new(record).call }

    context 'when only has first-level caching' do
      let(:attributes_to_cache) { [:id, :name ]}

      before do
        attributes_to_cache.each do |attribute|
          allow(record).to receive(attribute).and_return(fake_model[attribute])
        end
      end

      it "returns an object with cache set" do
        expect(subject).to have_key(:cache)
      end

      it 'returns the cache with only the asked parameters' do
        expect(subject[:cache].keys).to match_array(attributes_to_cache)
      end

      it 'returns the same parameters as the record' do
        attributes_to_cache.each do |attribute|
          expect(subject[:cache][attribute]).to be(fake_model[attribute])
        end
      end
    end

    context 'when has second-level caching' do
      let(:attributes_to_cache) { [mother: [:name], father: [:id]]}

      before do
        attributes_to_cache.first.each do |association_name, attributes|
          association = fake_model[association_name]

          allow(record).to receive(association_name).and_return(association)
          allow(association).to receive(:blank?).and_return(false)

          attributes.each do |attribute|
            allow(association).to receive(attribute).and_return(association[attribute])
          end
        end
      end

      it 'returns and object with attribute_cache set' do
        expect(subject.keys).to match_array(attributes_to_cache.first.keys.map{|key| "#{key}_cache"})
      end

      it 'returns the cache with only the asked parameters' do
        expect(subject.values.map(&:keys)).to match_array(attributes_to_cache.first.values)
      end

      it 'returns the same parameters as the record' do
        attributes_to_cache.first.each do |association_name, attributes|
          attributes.each do |attribute|
            expect(subject["#{association_name}_cache"][attribute]).to be(fake_model[association_name][attribute])
          end
        end
      end
    end

    context 'when has second-level caching with a multiple association' do
      let(:attributes_to_cache) { [houses: [:name]] }

      before do
        attributes_to_cache.first.each do |association_name, attributes|
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

      it 'returns and object with attribute_cache set' do
        expect(subject.keys).to match_array(attributes_to_cache.first.keys.map{|key| "#{key}_cache"})
      end

      it 'returns the cache with only the asked parameters' do
        expect(subject.values.first.map(&:keys).uniq).to match_array(attributes_to_cache.first.values)
      end

      it 'returns the same parameters as the record' do
        attributes_to_cache.first.each do |association_name, attributes|
          subject["#{association_name}_cache"].each_with_index do |cache, index|
            attributes.each do |attribute|
              expect(cache[attribute]).to be(fake_model[association_name][index][attribute])
            end
          end
        end
      end
    end
  end
end
