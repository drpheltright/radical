include Radical

product_schema = Typed::Hash[name: String]
product_list_schema = Typed::Array[product_schema]

class MultiPathRouteMock < Route[:users, Typed::Arg[id: Integer], :name, String]
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
