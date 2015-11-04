describe Radical::Router do
  let(:profile_schema) { Radical::Typed::Hash[name: String] }
  let(:line_items_schema) { Radical::Typed::Array[Radical::Typed::Hash[id: Integer]] }
  let(:cart_schema) { Radical::Typed::Hash[line_items: line_items_schema] }
  let(:user_schema) { Radical::Typed::Hash[profile: profile_schema, cart: cart_schema] }
  let(:dynamic_arg) { Radical::Typed::Arg[id: Integer] }

  let(:user_profile_route) do
    Radical::Route[:user, dynamic_arg, user_schema].define do
      def get(id)
        { profile: { name: 'Luke' } }
      end
    end
  end

  let(:user_cart_route) do
    Radical::Route[:user, dynamic_arg, user_schema].define do
      def get(id)
        { cart: { line_items: [{ id: 1 }, { id: 2 }] } }
      end
    end
  end

  let(:post_route) do
    Radical::Route[:blog, :latest_post, Radical::Typed::Hash[title: String]].define do
      def get
        { title: 'Very good post' }
      end
    end
  end

  let(:author_route) do
    Radical::Route[:blog, :featured_author, Radical::Typed::Hash[name: String]].define do
      def get
        { name: 'Luke' }
      end
    end
  end

  context 'when single request matches single dynamic route' do
    let(:routes) { [user_profile_route, post_route].map(&:new) }
    subject { Radical::Router.new(routes).route([[:get, :user, 1]])[:user][1] }

    it { is_expected.to include(profile: a_hash_including(name: 'Luke')) }
    it { is_expected.to_not include(blog: a_kind_of(Hash)) }
  end

  context 'when single request matches two dynamic routes' do
    let(:routes) { [user_profile_route, user_cart_route].map(&:new) }
    subject { Radical::Router.new(routes).route([[:get, :user, 1]])[:user][1] }

    it { is_expected.to include(profile: a_hash_including(name: 'Luke')) }
    it { is_expected.to include(cart: a_hash_including(line_items: be_a(Array))) }
  end

  context 'when single request matches two dynamic routes' do
    let(:routes) { [user_profile_route, user_cart_route].map(&:new) }
    subject { Radical::Router.new(routes).route([[:get, :user, 1]])[:user][1] }

    it { is_expected.to include(profile: a_hash_including(name: 'Luke')) }
    it { is_expected.to include(cart: a_hash_including(line_items: be_a(Array))) }
  end

  context 'when dynamic argument is typed as string' do
    let(:dynamic_arg) { Radical::Typed::Arg[id: String] }
    let(:routes) { [user_profile_route.new] }
    subject { Radical::Router.new(routes).route([[:get, :user, 1]]) }

    it { is_expected.to include(user: { "1" => a_kind_of(Hash) }) }
  end

  context 'when single request matches two static routes' do
    let(:routes) { [post_route, author_route].map(&:new) }
    subject { Radical::Router.new(routes).route([[:get, :blog, :latest_post], [:get, :blog, :featured_author]]) }

    it { is_expected.to include(blog: a_hash_including(:latest_post)) }
    it { is_expected.to include(blog: a_hash_including(:featured_author)) }
  end

  context 'when one request out of two matches route' do
    let(:routes) { [user_profile_route, user_cart_route].map(&:new) }
    subject { Radical::Router.new(routes).route([[:get, :user, 1], [:get, :blog, :latest_post]]) }

    it { is_expected.to include(errors: a_hash_including('get.blog.latest_post' => array_including(a_kind_of(String)))) }
  end
end
