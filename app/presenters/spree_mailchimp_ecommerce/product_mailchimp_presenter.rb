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
          url: ("#{domain_url(store)}/#{product.slug}" || ""),
          vendor: product.category&.name || "",
          image_url: image_url,
          variants: variants,
          store_id: store.id
        }.as_json
      end
    end

    private

    def variants
      product.has_variants? ? product.variants.map(&:mailchimp_variant).flatten : product.master.mailchimp_variant
    end

    def image_url
      product.mailchimp_image_url
    end

    def domain_url(store)
      return store.url if store.mailchimp_setting.present?
      ENV['FRONT_END_APP_URL']
    end
  end
end
