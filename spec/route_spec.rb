describe Radical::Route do
  context 'when defining single path' do
    let(:product_schema) { Radical::Typed::Hash[name: String] }

    let(:route) do
      Radical::Route[:products, Radical::Typed::Array[product_schema]].define do
        def get
          [{ name: 'Car' }]
        end
      end
    end

    subject { route.new.handle([:get, :products]) }

    it { is_expected.to include(products: array_including(a_hash_including(name: 'Car'))) }
  end
end
