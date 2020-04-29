# frozen_string_literal: true

module SpreeMailchimpEcommerce
  class UpdateUserJob < ApplicationJob
    def perform(mailchimp_user)
      return unless mailchimp_user

      gibbon_store(mailchimp_user["store_id"]).customers(mailchimp_user["id"]).update(body: mailchimp_user)
    end
  end
end
