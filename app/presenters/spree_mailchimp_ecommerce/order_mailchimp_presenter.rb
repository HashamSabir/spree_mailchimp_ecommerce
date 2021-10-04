# frozen_string_literal: true

module SpreeMailchimpEcommerce
  class OrderMailchimpPresenter
    include OrderMethods

    attr_reader :order

    def initialize(order)
      @order = order
      raise "Order in wrong state" unless order.completed?
    end

    def json
      tax_total = if order.respond_to?(:price_values)
        order.tp(order.float_tp(order.price_values[:prices][:included_tax_total]) + order.float_tp(order.price_values[:prices][:additional_tax_total]))
      else
        order.tax_total
      end

      order_json.merge(campaign_id).merge(promotions).merge(
        {
          processed_at_foreign: order.completed_at.strftime("%Y%m%dT%H%M%S"),
          discount_total: (order.respond_to?(:price_values) ? order.price_values[:prices][:promo_total] : order.promo_total),
          tax_total: tax_total,
          shipping_total: (order.respond_to?(:price_values) ? order.price_values[:prices][:ship_total] : order.ship_total),
          shipping_address: order_address(order.shipping_address),
          billing_address: order_address(order.billing_address),
          order_url: "#{order.store.domain_url}/cart"
        }.as_json
      )
    end

    private

    def campaign_id
      return {} unless order.mailchimp_campaign_id

      { campaign_id: order.mailchimp_campaign_id }.as_json
    end

    def promotions
      return {} unless promotions_list.any?

      promos = promotions_list.map do |p|
        rules = PromoRuleMailchimpPresenter.new(p).json
        rules.map do |rule|
          {
            code: p.code,
            amount_discounted: rule['amount'],
            type: rule['type']
          }
        end
      end
      { promos: promos.flatten }
    end

    def promotions_list
      order.all_adjustments.eligible.nonzero.promotion.map(&:source).map(&:promotion).uniq rescue []
    end

    def user
      if order.user
        UserMailchimpPresenter.new(order.user).json
      elsif order.email
        {
          id: Digest::MD5.hexdigest(order.email.downcase),
          first_name: order.bill_address&.firstname || "",
          last_name: order.bill_address&.last_name || "",
          email_address: order.email || "",
          opt_in_status: false,
          address: customer_address(order.shipping_address)
        }
      end
    end

    def customer_address(address)
      return {} unless address

      AddressMailchimpPresenter.new(address).json
    end

    def order_address(address)
      customer_address(address).merge({ name: address&.full_name }.as_json)
    end
  end
end
