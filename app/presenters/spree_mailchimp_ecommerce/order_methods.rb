module SpreeMailchimpEcommerce
  module OrderMethods
    def order_json
      return {} unless user

      {
        id: order.number,
        customer: user,
        currency_code: order.currency || order.store&.default_currency || ::Spree::Config[:currency],
        order_total: (order.respond_to?(:price_values) ? order.price_values[:prices][:payable_amount] : order.total),
        lines: lines,
        store_id: order.store_id.to_s
      }.as_json
    end

    private

    def lines
      order.line_items.map(&:mailchimp_line_item)
    end
  end
end
