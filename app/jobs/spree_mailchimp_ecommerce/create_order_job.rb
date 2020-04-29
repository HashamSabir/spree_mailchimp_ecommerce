# frozen_string_literal: true

module SpreeMailchimpEcommerce
  class CreateOrderJob < ApplicationJob
    def perform(mailchimp_order)
      begin
        gibbon_store(mailchimp_order["store_id"]).orders.create(body: mailchimp_order)
      rescue Gibbon::MailChimpError => e
        Rails.logger.error("[MAILCHIMP] Error while creating order: #{e}")
      end
    end
  end
end
