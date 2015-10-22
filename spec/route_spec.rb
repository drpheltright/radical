describe Radical::Route do
  context 'when defining single path' do
    let(:product_schema) { Radical::Typed::Hash[name: String] }

    let(:route) do
      Radical::Route[:products, Radical::Typed::Array[product_schema]].define do
        def initialize
          @products = [{ name: 'Car' }]
        end

        def get
          @products
        end

        def set(products)
          @products = products
        end
      end
    end

    context 'when getting data' do
      subject { route.new.handle([:get, :products]) }
      it { is_expected.to include(products: array_including(a_hash_including(name: 'Car'))) }
    end

    context 'when setting data' do
      let(:updated_product) { { name: 'Bob' } }
      let(:route_instance) { route.new }

      before(:each) do
        expect(route_instance).to receive(:set).with([updated_product]).and_call_original
      end

      subject { route_instance.handle([:set, :products, [updated_product]]) }
      it { is_expected.to include(products: array_including(a_hash_including(name: 'Bob'))) }
    end
  end
end
