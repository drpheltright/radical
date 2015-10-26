describe Radical::Router do
  context 'when single request matches single route' do
  end

  context 'when single request matches two routes' do
    let(:profile_schema) { Radical::Typed::Hash[name: String] }
    let(:line_items_schema) { Radical::Typed::Array[Radical::Typed::Hash[id: Integer]] }
    let(:cart_schema) { Radical::Typed::Hash[line_items: line_items_schema] }
    let(:user_schema) { Radical::Typed::Hash[profile: profile_schema, cart: cart_schema] }

    let(:route_1) do
      Radical::Route[:user, Radical::Arg[:id], user_schema].define do
        def get(id)
          { profile: { name: 'Luke' } }
        end
      end
    end

    let(:route_2) do
      Radical::Route[:user, Radical::Arg[:id], user_schema].define do
        def get(id)
          { cart: { line_items: [{ id: 1 }, { id: 2 }] } }
        end
      end
    end

    let(:routes) { [route_1, route_2].map(&:new) }

    subject { Radical::Router.new(routes).route([[:get, :user, 1]])[:user][1] }

    it { is_expected.to include(profile: a_hash_including(name: 'Luke')) }
    it { is_expected.to include(cart: a_hash_including(line_items: be_a(Array))) }
  end
end
