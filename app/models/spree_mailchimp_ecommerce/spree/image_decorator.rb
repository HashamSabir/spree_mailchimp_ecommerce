module SpreeMailchimpEcommerce
  module Spree
    module ImageDecorator
      def self.prepended(base)
        base.after_create :update_mailchimp_product
        base.after_update :update_mailchimp_product
        base.after_destroy :update_mailchimp_product
      end

      private

      def update_mailchimp_product

        find_product.mailchimp_product.each do |pro|
          ::SpreeMailchimpEcommerce::UpdateProductJob.perform_later(pro)
        end        
      end

      def find_product
        ::Spree::Variant.unscoped.find(viewable_id).product
      end
    end
  end
end
Spree::Image.prepend(SpreeMailchimpEcommerce::Spree::ImageDecorator)
