describe Radical::Application do
  let(:router) { double(route: { name: 'Luke' }) }
  let(:request) { Rack::MockRequest.env_for('/', params: { routes: ['get.name'] }) }

  before(:each) do
    app = Radical::Application.new
    app.router = router
    app.call(request)
  end

  it 'should forward request to router' do
    expect(router).to have_received(:route).with([[:get, :name]])
  end
end
