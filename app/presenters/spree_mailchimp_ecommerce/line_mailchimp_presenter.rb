# frozen_string_literal: true

module SpreeMailchimpEcommerce
  class LineMailchimpPresenter
    attr_reader :line

    def initialize(line)
      @line = line
    end

    def json
      {
        id: Digest::MD5.hexdigest("#{line.id}#{line.order_id}"),
        product_id: ProductMailchimpPresenter.new(line.product).json[0]["id"],
        product_variant_id: Digest::MD5.hexdigest("#{line.variant.sku}#{line.variant.id}#{line.order.store_id.to_s}"),
        quantity: line.quantity || 0,
        price: (line.price_values[:price] rescue "0")
      }
    end
  end
end
