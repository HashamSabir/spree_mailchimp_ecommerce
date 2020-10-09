module SpreeMailchimpEcommerce
  module Spree
    module StockItemDecorator
      def self.prepended(base)
        base.after_save :update_product
      end

      private

      def update_product
        return unless count_on_hand_previously_changed? || count_on_hand_changed?
        return unless product&.mailchimp_product.present?

        product.mailchimp_product.each do |pro|
          ::SpreeMailchimpEcommerce::UpdateProductJob.perform_later(pro)
        end
      end
    end
  end
end
Spree::StockItem.prepend(SpreeMailchimpEcommerce::Spree::StockItemDecorator)
