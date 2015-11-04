product_schema = Radical::Typed::Hash[name: String]
product_list_schema = Radical::Typed::Array[product_schema]

class MultiPathRouteMock < Radical::Route[:users, Radical::Arg[id: Integer], :name, String]
  def initialize
    @name = {}
  end

  def get(id)
    @name[id]
  end

  def set(id, name)
    @name[id] = name
  end
end
