RSpec.describe SystemsData do

  let(:test_config_path) { test_data_dir('.oolite') }
  let(:load_config) { Oolite.load_configuration(test_config_path) }

  before do
    load_config
  end

  it 'can be instantiated' do
    expect(SystemsData.systems).to_not be nil
  end

  it 'loads system data from config' do
    expect(SystemsData.systems.count).to be >= 28
    ensoreus = SystemsData.systems['Ensoreus']

    expect(ensoreus.name).to eq "Ensoreus"
    expect(ensoreus.economy).to eq "Rich Industrial"
    expect(ensoreus.government).to eq "Corporate State"
    expect(ensoreus.tech_level).to eq "12"
  end
end
