describe Radical::Route do
  context 'when getting route with single path' do
    let(:route) { Radical::Route[:name, String].define { def get; :Luke; end } }
    subject { route.new.handle([:get, :name]) }
    it { is_expected.to include(name: 'Luke') }
  end

  context 'when getting route with two part path' do
    let(:route) { Radical::Route[:person, :name, String].define { def get; :Luke; end } }
    subject { route.new.handle([:get, :person, :name]) }
    it { is_expected.to include(person: a_hash_including(name: 'Luke')) }
  end

  context 'when getting route with four part path' do
    let(:route) { Radical::Route[:user, :profile, :friend, :name, String].define { def get; :Luke; end } }
    subject { route.new.handle([:get, :user, :profile, :friend, :name]) }
    it { is_expected.to include(user: a_hash_including(
                                  profile: a_hash_including(
                                    friend: a_hash_including(
                                      name: 'Luke')))) }
  end

  context 'when getting route with dynamic arg in path' do
    let(:route) { Radical::Route[:users, dynamic_arg, :name, String].define { def get(id); :Luke; end } }
    subject { route.new.handle([:get, :users, 1, :name]) }

    context 'and dynamic arg is string' do
      let(:dynamic_arg) { Radical::Typed::Arg[:id] }
      it { is_expected.to include(users: a_hash_including('1' => a_hash_including(name: 'Luke'))) }
    end

    context 'and dynamic arg is int' do
      let(:dynamic_arg) { Radical::Typed::Arg[id: Integer] }
      it { is_expected.to include(users: a_hash_including(1 => a_hash_including(name: 'Luke'))) }
    end
  end

  context 'when setting route with single path' do
    let(:route) { SinglePathRouteMock }
    let(:updated_product) { { name: 'Bob' } }
    let(:route_instance) { route.new }

    before(:each) do
      expect(route_instance).to receive(:set).with([updated_product]).and_call_original
    end

    subject { route_instance.handle([:set, :products, [updated_product]]) }
    it { is_expected.to include(products: array_including(a_hash_including(name: 'Bob'))) }
  end

  context 'when setting route with dynamic arg in path' do
    let(:route) { MultiPathRouteMock }
    subject { route.new.handle([:set, :users, 1, :name, 'Dave']) }
    it { is_expected.to include(users: a_hash_including(1 => a_hash_including(name: 'Dave'))) }
  end

  context 'when route given request with method it does not support' do
    let(:route) { Radical::Route[:name, String] }
    subject { route.new.handle([:get, :name]) }
    it { is_expected.to be_nil }
  end

  context 'when route given request with path it does not support' do
    let(:route) { Radical::Route[:name, String].define { def get; end } }
    subject { route.new.handle([:get, :bob]) }
    it { is_expected.to be_nil }
  end
end
