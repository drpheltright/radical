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

  HashList = Typed::Array[Cool]
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

Schema::HashList.new([1])
Schema::IntList.new([1])
person = Schema::Person.new(name: 'Luke',
                            ages: ['10'],
                            properties: [{ name: 'Color', value: 'Blue', hmm: true }])
p person[:properties].first[:name]

p Route.registered_routes.each do |route_class|
  p route_class.new.respond_to?(:get)
end
