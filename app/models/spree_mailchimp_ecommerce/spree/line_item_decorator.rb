module SpreeMailchimpEcommerce
  module Spree
    module LineItemDecorator
      def self.prepended(base)
        base.after_update :update_mailchimp_cart, if: :mailchimp_setting_present?
        base.after_create :handle_cart, if: :mailchimp_setting_present?
        base.after_destroy :delete_line_item, if: :mailchimp_setting_present?
      end

      def handle_cart
        return unless order.user

        order.mailchimp_cart_created ? update_mailchimp_cart : order.create_mailchimp_cart
      end

      def mailchimp_line_item
        ::SpreeMailchimpEcommerce::LineMailchimpPresenter.new(self).json
      end

      private

      def update_mailchimp_cart
        order.update_mailchimp_cart
      end

      def delete_line_item
        ::SpreeMailchimpEcommerce::DeleteLineItemJob.perform_later(self)
      end

      def mailchimp_setting_present?
        setting = self.store.mailchimp_setting || MailchimpSetting.find_by(store_id: nil)
        setting.present?
      end
    end
  end
end
Spree::LineItem.prepend(SpreeMailchimpEcommerce::Spree::LineItemDecorator)
