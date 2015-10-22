describe Radical::Typed::Array do
  context 'when given correct data type' do
    subject { Radical::Typed::Array[String].new(['Cool']) }
    it { is_expected.to include('Cool') }
  end

  context 'when given incorrect data type' do
    subject { Radical::Typed::Array[String].new([10]) }
    it { is_expected.to include('10') }
  end
end
