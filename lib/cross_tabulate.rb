# CrossTabulate

module ActiveRecord
  class Base
    # A cross tabulation compares one variable against the tabulation of another variable. This is often useful
    # when you need to aggregate data in categories.
    #
    # For example, you may want to find the sum of sales for each department in a supermarket. Given the schema:
    #
    #   Departments: id, name
    #   Sales: id, department_id, amount
    #
    # and the example data:
    #
    # Departments:
    #   +------------------+
    #   | id |    name     |
    #   |----+-------------+
    #   | 1  | Vegetables  |
    #   | 2  | Deli        |
    #   | 3  | Frozen      |
    #   +------------------+
    #
    # Sales:
    #   +-----------------------------+
    #   | id | department_id | amount |
    #   |----+---------------+--------+
    #   | 1  |       1       | 11     |
    #   | 1  |       1       | 111    |
    #   | 2  |       2       | 22     |
    #   | 2  |       2       | 222    |
    #   | 3  |       3       | 3      |
    #   +-----------------------------+
    #
    # You would want the output:
    #   +----------------------------+
    #   | Vegetables | Deli | Frozen |
    #   |------------+------+--------+
    #   |    122     |  244 |   3    |
    #   +----------------------------+
    #
    # Which could be achieved using the method call:
    #
    #   Department.cross('name', :aggregator => 'sum', aggregator_column => 'amount', :joins => 'INNER JOIN sales ON sales.department_id = departments.id')
    #
    # ==== Parameters
    #
    # * <tt>:column</tt> - The name of the column to build categories. This can include table names if crossing on a join table such as 'sales.department_id'.
    # * <tt>:options</tt> - A hash of the same parameters acceptable by find with the addition of 'aggregator' and 'aggregator_column'.
    #   The aggregator defaults to 'count' and determines how to process the data for each category. By default, the aggregator will operate
    #   on the category column, but you can override this by setting the :aggregator_column option.
    #
    # This method will return an array of hashes, with one hash for each group. Hash keys are column names, and their values are the aggregate values.
    def cross(column, options={})
      options = {:aggregator => 'count', :aggregator_column => column}.merge(options)

      sql = construct_finder_sql(options.merge(:select => connection.distinct(column,'')).except(:group))
      categories = connection.select_values(sql)

      categories.map! {|category| "#{options[:aggregator]}(CASE WHEN #{column}=#{quote_value(category)} THEN #{options[:aggregator_column]} ELSE NULL END) AS #{quote_value(category)}"}
      options[:select] = [options[:group], options[:select]].concat(categories).compact.join(',')
      connection.select_all(construct_finder_sql(options))
    end
  end
end