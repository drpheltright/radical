product_schema = Radical::Typed::Hash[name: String]
product_list_schema = Radical::Typed::Array[product_schema]

class SinglePathRouteMock < Radical::Route[:products, product_list_schema]
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
