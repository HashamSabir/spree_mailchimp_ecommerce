# frozen_string_literal: true

module SpreeMailchimpEcommerce
  class CreateUserJob < ApplicationJob
    def perform(mailchimp_user)
      begin
        gibbon_store(mailchimp_user["store_id"]).customers.create(body: mailchimp_user)
      rescue Gibbon::MailChimpError => e
        Rails.logger.error("[MAILCHIMP] Error while creating user: #{e}")
      end
    end
  end
end
