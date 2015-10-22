describe Radical::Route do
  context 'when defining single path' do
    let(:product_schema) { Radical::Typed::Hash[name: String] }

    let(:route) do
      Radical::Route[:products, Radical::Typed::Array[product_schema]].define do
        def get
          [{ name: 'Car' }]
        end

        def set(product)
        end
      end
    end

    context 'when getting data' do
      subject { route.new.handle([:get, :products]) }
      it { is_expected.to include(products: array_including(a_hash_including(name: 'Car'))) }
    end

    context 'when setting data' do
      let(:updated_product) { { name: 'Bob' } }
      subject { route.new }

      before(:each) do
        expect(subject).to receive(:set).with([updated_product])
        subject.handle([:set, :products, [updated_product]])
      end

      # it { is_expected.to include(products: array_including(a_hash_including(name: 'Bob'))) }
      it do; end
    end
  end
end
