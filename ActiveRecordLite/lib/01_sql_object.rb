require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns

    query = "select * from #{self.table_name} limit 1"
    @@columns ||= DBConnection.execute2(query)
    [:id, :name, :owner_id]
  end

  def self.finalize!
    (self.columns).each do |col|
      define_method(col) do
        attributes[col]
      end
      define_method("#{col}=") do |value|
        attributes[col] = value
      end
    end
  end

  def self.table_name=(table_name)
    snaked = self.camel_to_snake_case(table_name)
    @@table_name = self.pluralize(snaked.downcase)
  end

  def self.table_name
    @@table_name ||= self.pluralize(self.camel_to_snake_case(self.to_s))
  end

  def self.camel_to_snake_case(to_snake)
    snaked = ""
    to_snake.each_char.with_index do |ch, i|
      if ch == ch.upcase && i > 0
        snaked += '_'
      end
      snaked += ch.downcase
    end
    snaked
  end

  def self.pluralize(name)
    if name[-1] == 's'
      name
    elsif name[-1] == 'y'
      name[0...-1] + 'ies'
    else
      name + 's'
    end
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    SQLObject.finalize! #unless params.empty?
    params.each do |attr_name,v|
      unless SQLObject.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      if v
        self.send(attr_name.to_sym, v)
      elsif attr_name
        self.send(attr_name.to_sym)
      end
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end


end
