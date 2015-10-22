$:.unshift File.dirname(__FILE__) + '/lib'
require 'pry-byebug'
require 'radical'
include Radical

module Schema
  Product = Typed::Hash[name: String,
                        url: String,
                        properties: Typed::Array[:Property]]

  Property = Typed::Hash[name: String, value: String]

  ProductList = Typed::Array[Product]

  LineItem = Typed::Hash[product: Product, qty: Integer]

  Cart = Typed::Hash[line_items: Typed::Array[LineItem]]

  User = Typed::Hash[name: String, cart: Cart]
end

# Block style definition
#
Route[:products, Schema::ProductList].define do
  def get
    [:product_1, :product_2]
  end
end

# Class based definition
#
class ProductByPidRoute < Route[:product_by_pid, Arg[:pid], Schema::Product]
  def get(pid)
    [:product_with_pid]
  end
end

# Class override
#
# By extending any route you are effectively saying this new implmentation
# should be used instead.
#
class OverriddenProductByPidRoute < ProductByPidRoute
end

module Schema
  class Cool
  end

  class Bob
    def self.coerce(value)
      new
    end
  end

  CoolList = Typed::Array[Cool]
  BobList = Typed::Array[Bob]
  IntList = Typed::Array[Integer]

  PropertyList = Typed::Array[Property]

  AgeList = Typed::Array[Integer]
  Person = Typed::Hash[name: String,
                       ages: AgeList,
                       properties: PropertyList]
end

def Schema::Cool(any)
  Schema::Cool.new
end

p Schema::CoolList.new(['1']).to_a
p Schema::BobList.new(['1']).to_a
p Schema::IntList.new(['30']).to_a

person = Schema::Person.new(name: 'Luke',
                            ages: ['25'],
                            properties: [{ name: 'Favourite Number', value: 10 }])
p person.to_h

Route.registered_routes.each do |route_class|
  p route_class
end

router = Router.new(Route.registered_routes.map(&:new))
p router.route([[:get, :products]])
