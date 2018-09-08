require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do
        attributes[col]
      end
      define_method("#{col}=") do |value|
        attributes[col] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
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
    res = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL
    all_params = []
    res.each do |params|
        new_params = {}
        params.each { |k, v| new_params[k.to_sym] = v }
        all_params << new_params
    end
    self.parse_all(all_params)
  end

  def self.parse_all(results)
    results.map { |params| new(params)}
  end

  def self.find(id)

    res = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{self.table_name}
      WHERE id = ?
    SQL
    res.empty? ? nil : res
  end

  def initialize(params = {})
    params.each do |attr_name,v|
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      if v
        send("#{attr_name.to_sym}=", v)
      elsif attr_name
        send(attr_name.to_sym)
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
