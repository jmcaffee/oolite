RSpec.describe SystemData do

  #let(:test_config_path) { test_data_dir('.oolite') }
  #let(:load_config) { Oolite.load_configuration(test_config_path) }

  #before do
  #  load_config
  #end

  let(:system_data) do
    data = {
      economy: 'economy',
      government: 'government',
      tech_level: '12'
    }
  end

  let(:empty_system_data) do
    data = {
      economy: '',
      government: '',
      tech_level: ''
    }
  end

  it 'can be instantiated' do
    expect(SystemData.new('name', system_data)).to_not be nil
  end

  it 'stores data' do
    actual = SystemData.new('name', system_data)

    expect(actual.name).to eq 'name'
    expect(actual.economy).to eq system_data[:economy]
    expect(actual.government).to eq system_data[:government]
    expect(actual.tech_level).to eq system_data[:tech_level]
  end

  it 'emits a hash for yaml storage' do
    actual = SystemData.new('name', system_data)

    expect(actual.to_yaml).to eq system_data
  end

  it 'can tell if all data is present' do
    sysdata = SystemData.new('name', empty_system_data)

    expect(sysdata.all_data_present?).to eq false

    sysdata.economy = 'econ'
    expect(sysdata.all_data_present?).to eq false

    sysdata.government = 'gov'
    expect(sysdata.all_data_present?).to eq false

    sysdata.tech_level = '12'
    expect(sysdata.all_data_present?).to eq true
  end
end
