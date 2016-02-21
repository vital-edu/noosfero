ActiveRecord::Calculations.class_eval do
  def count_with_distinct column_name=nil
    distinct.count_without_distinct column_name
  end
  alias_method_chain :count, :distinct
end
