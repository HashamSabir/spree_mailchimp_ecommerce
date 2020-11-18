# frozen_string_literal: true

module SpreeMailchimpEcommerce
  class ProductMailchimpPresenter
    attr_reader :product

    def initialize(product)
      @product = product
    end

    def json
      product.stores.map do |store|
        {
          id: Digest::MD5.hexdigest(product.id.to_s),
          title: product.name || "",
          description: product.description || "",
          url: ("#{store.domain_url}/#{product.slug}" || ""),
          vendor: product.category&.name || "",
          image_url: image_url,
          variants: variants.select{ |variant| variant["store_id"].eql? store.id.to_s },
          store_id: store.id.to_s
        }.as_json
      end
    end

    private

    def variants
      product.has_variants? ? product.variants.map(&:mailchimp_variant).flatten.uniq : product.master.mailchimp_variant.uniq
    end

    def image_url
      product.mailchimp_image_url
    end
  end
end
