require 'rails_helper'

RSpec.describe AttendanceTaker do
  it 'can convert a column index to a single letter identifier' do
    expect(AttendanceTaker.column_name(0)).to eq('A')
    expect(AttendanceTaker.column_name(1)).to eq('B')
  end

  it 'can convert a column index greater than 25 to two letter indetifiers' do
    expect(AttendanceTaker.column_name(26)).to eq('AA')
    expect(AttendanceTaker.column_name(27)).to eq('AB')
  end

  it 'can convert a column index greater than 51 to two letter indentifiers' do
    expect(AttendanceTaker.column_name(65)).to eq('BN')
  end
end
