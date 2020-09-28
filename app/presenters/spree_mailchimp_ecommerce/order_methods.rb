module SpreeMailchimpEcommerce
  module OrderMethods
    def order_json
      return {} unless user

      {
        id: order.number,
        customer: user,
        currency_code: order.currency || order.store&.default_currency || ::Spree::Config[:currency],
        order_total: (order.price_values[:prices][:payable_amount] rescue "0"),
        lines: lines,
        store_id: order.store_id
      }.as_json
    end

    private

    def lines
      order.line_items.map(&:mailchimp_line_item)
    end
  end
end
