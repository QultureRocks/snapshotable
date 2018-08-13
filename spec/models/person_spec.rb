# frozen_string_literal: true

RSpec.describe Person do
  let(:record) { create(:person) }

  let!(:record_first_snapshot) { create(:person_snapshot, person: record, created_at: 5.day.ago) }
  let!(:record_second_snapshot) { create(:person_snapshot, person: record, created_at: 3.day.ago) }
  let!(:record_third_snapshot) { create(:person_snapshot, person: record, created_at: 1.day.ago) }
  let(:record_snapshots) { [record_first_snapshot, record_second_snapshot, record_third_snapshot] }

  let!(:other_person_snapshots) { create_list(:person_snapshot, 2) }

  describe '#snapshots' do
    subject { record.snapshots }

    it 'returns all record snapshots' do
      expect(subject.pluck(:id)).to include(*record_snapshots.map(&:id))
      expect(subject.pluck(:id)).to_not include(*other_person_snapshots.map(&:id))
    end
  end

  describe '#last_snapshot_before' do
    subject { record.last_snapshot_before(time) }

    context 'there is a snapshot' do
      let(:time) { 2.day.ago }
      it 'returns the last snapshot before passed date' do
        expect(subject).to eq(record_second_snapshot)
      end
    end

    context 'there isn\'t a snapshot' do
      let(:time) { 10.day.ago }
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#take_snapshot!' do
    it 'only creates if something has changed' do
      expect { record.take_snapshot! }.to_not(change { PersonSnapshot.count })

      record.update!(name: 'New name')
      record.reload

      expect { record.take_snapshot! }.to change { PersonSnapshot.count }.by(1)
    end
  end
end
