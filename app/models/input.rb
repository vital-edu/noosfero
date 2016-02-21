class Input < ActiveRecord::Base

  belongs_to :product
  belongs_to :product_category

  validates_presence_of :product
  validates_presence_of :product_category

  acts_as_list scope: -> input { where product_id: input.product_id }

  belongs_to :unit

  scope :relevant_to_price, -> { where relevant_to_price: true }

  include FloatHelper

  def price_per_unit=(value)
    if value.is_a?(String)
      super(decimal_to_float(value))
    else
      super(value)
    end
  end

  def amount_used=(value)
    if value.is_a?(String)
      super(decimal_to_float(value))
    else
      super(value)
    end
  end

  def name
    product_category.name
  end

  def formatted_value(value)
    ("%.2f" % self[value]).to_s.gsub('.', product.enterprise.environment.currency_separator) if self[value]
  end

  def formatted_amount
    amount = self.amount_used
    return '' if amount.blank? || amount.zero?
    ("%.2f" % amount).to_s.gsub('.00', '').gsub('.', product.enterprise.environment.currency_separator)
  end

  def has_price_details?
    %w[price_per_unit amount_used].each do |field|
      return true unless self.send(field).blank?
    end
    false
  end

  def has_all_price_details?
    %w[price_per_unit unit amount_used].each do |field|
      return false if self.send(field).blank?
    end
    true
  end

  def cost
    return 0 if self.amount_used.blank? || self.price_per_unit.blank?
    self.amount_used * self.price_per_unit
  end

  alias_method :price, :cost

end
