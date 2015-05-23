RSpec.describe SystemsData do

  let(:test_config_path) { temp_from_data_dir('.oolite') }
  let(:load_config) { Oolite.load_configuration(test_config_path) }

  before do
    load_config
  end

  it 'loads systems data from config' do
    expect(SystemsData.systems.count).to be >= 28
    ensoreus = SystemsData.systems['Ensoreus']

    expect(ensoreus.name).to eq "Ensoreus"
    expect(ensoreus.economy).to eq "Rich Industrial"
    expect(ensoreus.government).to eq "Corporate State"
    expect(ensoreus.tech_level).to eq "12"
  end

  it 'returns list of system names' do
    names = SystemsData.names
    expect(names).to include 'Ensoreus'
    expect(names).to include 'Lave'
    expect(names).to include 'Diso'
  end

  it 'adds to the list' do
    expect(SystemsData.names).to_not include 'New System'
    new_sys = SystemData.new('New System', { economy: 'Economy', government: 'Government', tech_level: '12'} )

    SystemsData.add new_sys
    expect(SystemsData.names).to include 'New System'
    expect(SystemsData.systems['New System']).to eq new_sys

    expect(file_contains(test_config_path, 'New SysteM'))
  end
end
