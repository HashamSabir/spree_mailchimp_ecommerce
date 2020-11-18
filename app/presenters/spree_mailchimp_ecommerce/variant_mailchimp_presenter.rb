# frozen_string_literal: true

module SpreeMailchimpEcommerce
  class VariantMailchimpPresenter
    attr_reader :variant

    def initialize(variant)
      @variant = variant
    end

    def json
      variant.product.stores.map do |store|
        {
          id: Digest::MD5.hexdigest("#{variant.sku}#{variant.id}#{store.id.to_s}"),
          title: variant.name || "",
          sku: variant.sku || variant.id,
          inventory_quantity: variant.stock_items.sum(&:count_on_hand),
          price: (variant.price || 0).to_s,
          url: ("#{store.domain_url}/#{variant.slug}" || ""),
          store_id: store.id.to_s
        }.as_json
      end
    end
  end
end
