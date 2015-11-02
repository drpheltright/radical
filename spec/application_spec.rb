describe Radical::Application do
  let(:app) { Radical::Application.new }
  let(:response) { app.call(request) }

  context 'when valid get request made' do
    context 'and a route matches request' do
      let(:request) { Rack::MockRequest.env_for('/', params: { route: { name: nil } }) }
      let(:router) { double(route: { name: 'Luke' }) }
      before(:each) { app.router = router }

      context 'then the application' do
        it 'should forward request to router with params' do
          response
          expect(router).to have_received(:route).with([[:get, :name]])
        end
      end

      context 'then the response status' do
        subject { response.status }
        it { is_expected.to eq(200) }
      end

      context 'then the response body' do
        subject { response.body.first }
        it { is_expected.to eq(JSON.dump(name: 'Luke')) }
      end
    end

    context 'and only one route matches' do
      let(:request) { Rack::MockRequest.env_for('/', params: { route: { products: nil, nothing: nil } }) }
      let(:route) { SinglePathRouteMock.new }
      let(:router) { Radical::Router.new([route]) }
      before(:each) { app.router = router }

      context 'then the response status' do
        subject { response.status }
        it { is_expected.to eq(200) }
      end

      context 'then the response body' do
        subject { JSON.parse(response.body.first) }
        it { is_expected.to include('products' => a_kind_of(Array)) }
        it { is_expected.to include('errors' => { 'get.nothing' => array_including(a_kind_of(String)) }) }
      end
    end

    context 'and no route matches' do
      let(:request) { Rack::MockRequest.env_for('/', params: { route: { nothing: nil } }) }

      context 'then the response status' do
        subject { response.status }
        it { is_expected.to eq(200) }
      end

      context 'then the response body' do
        subject { JSON.parse(response.body.first) }
        it { is_expected.to include('errors' => { 'get.nothing' => array_including(a_kind_of(String)) }) }
      end
    end
  end

  context 'when valid set request made' do
    let(:request) { Rack::MockRequest.env_for('/', params: { route: { name: 'Bob' } }) }
    let(:router) { double(route: { name: 'Luke' }) }
    before(:each) { app.router = router }

    context 'then the application' do
      it 'should forward request to router with params' do
        response
        expect(router).to have_received(:route).with([[:set, :name, 'Bob']])
      end
    end

    context 'and a route matches request' do
      context 'then the response status' do
        subject { response.status }
        it { is_expected.to eq(200) }
      end

      context 'then the response body' do
        subject { response.body.first }
        it { is_expected.to eq(JSON.dump(name: 'Luke')) }
      end
    end
  end

  context 'when request invalid' do
    let(:request) { Rack::MockRequest.env_for('/') }

    context 'then the response status' do
      subject { response.status }
      it { is_expected.to eq(400) }
    end

    context 'then the response body' do
      subject { JSON.parse(response.body.first) }
      it { is_expected.to include('errors' => a_hash_including('global' => array_including(a_kind_of(String)))) }
    end
  end
end
