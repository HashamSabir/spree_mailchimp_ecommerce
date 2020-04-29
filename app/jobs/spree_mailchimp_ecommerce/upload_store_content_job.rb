module SpreeMailchimpEcommerce
  class UploadStoreContentJob < ApplicationJob
    def perform(*_args)
      begin
        mailchimp_setting = _args[0]
        gibbon_store(mailchimp_setting.store_id).update(body: { is_syncing: true })

        mailchimp_setting.update(state: 'syncing')
        ::Spree::Product.find_each do |product|
          product.mailchimp_product.each do |pro|
            ::SpreeMailchimpEcommerce::CreateProductJob.perform_now(pro)
          end
        end

        ::Spree::User.where.not(email: nil).find_each do |user|
          ::SpreeMailchimpEcommerce::CreateUserJob.perform_now(user.mailchimp_user)
        end

        ::Spree::Order.complete.find_each do |order|
          ::SpreeMailchimpEcommerce::CreateOrderJob.perform_now(order.mailchimp_order)
        end

        ::Spree::Promotion.find_each do |promotion|
          ::SpreeMailchimpEcommerce::CreatePromoRuleJob.perform_now(promotion.mailchimp_promo_rule)
          ::SpreeMailchimpEcommerce::CreatePromoCodeJob.perform_now(promotion.mailchimp_promo_rule, promotion.mailchimp_promo_code)
        end
      rescue Gibbon::MailChimpError => e
        Rails.logger.error("[MAILCHIMP] Error while syncing process: #{e}")
      end
    ensure
      gibbon_store(mailchimp_setting.store_id).update(body: { is_syncing: false })

      mailchimp_setting.update(state: 'ready')
    end
  end
end
