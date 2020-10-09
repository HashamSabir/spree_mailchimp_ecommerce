module SpreeMailchimpEcommerce
  module Spree
    module ImageDecorator
      def self.prepended(base)
        base.after_create :update_mailchimp_product, if: Proc.new {|img| img.viewable_id.present? }
        base.after_update :update_mailchimp_product, if: Proc.new {|img| img.viewable_id.present? }
        base.after_destroy :update_mailchimp_product, if: Proc.new {|img| img.viewable_id.present? }
      end

      private

      def update_mailchimp_product
        return true unless viewable_id.present? # no need to proceed

        find_product&.mailchimp_product&.each do |pro|
          ::SpreeMailchimpEcommerce::UpdateProductJob.perform_later(pro)
        end
      end

      def find_product
        ::Spree::Variant.unscoped.find_by_id(viewable_id)&.product
      end
    end
  end
end
Spree::Image.prepend(SpreeMailchimpEcommerce::Spree::ImageDecorator)
