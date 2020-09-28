module SpreeMailchimpEcommerce
  module Spree
    module PromotionDecorator
      def self.prepended(base)
        base.after_create :create_mailchimp_promotion
        base.after_update :update_mailchimp_promotion
        base.after_destroy :delete_mailchimp_promotion
      end

      def mailchimp_promo_rule
        ::SpreeMailchimpEcommerce::PromoRuleMailchimpPresenter.new(self).json
      end

      def mailchimp_promo_code(store_url)
        ::SpreeMailchimpEcommerce::PromoCodeMailchimpPresenter.new(self, store_url).json
      end

      private

      def create_mailchimp_promotion
        mailchimp_promo_rule.each do |rule|
          ::SpreeMailchimpEcommerce::CreatePromoJob.perform_later(rule, mailchimp_promo_code(rule["store_url"]))
        end
      end

      def update_mailchimp_promotion
        mailchimp_promo_rule.each do |rule|
          ::SpreeMailchimpEcommerce::UpdatePromoJob.perform_later(rule, mailchimp_promo_code(rule["store_url"]))
        end
      end

      def delete_mailchimp_promotion
        mailchimp_promo_rule.each do |rule|
          ::SpreeMailchimpEcommerce::DeletePromoJob.perform_later(rule, mailchimp_promo_code(rule["store_url"]))
        end
      end
    end
  end
end
Spree::Promotion.prepend(SpreeMailchimpEcommerce::Spree::PromotionDecorator)
