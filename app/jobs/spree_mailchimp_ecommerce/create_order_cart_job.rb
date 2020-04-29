# frozen_string_literal: true

module SpreeMailchimpEcommerce
  class CreateOrderCartJob < ApplicationJob
    def perform(mailchimp_cart)
      gibbon_store(mailchimp_cart["store_id"]).carts.create(body: mailchimp_cart)
    end
  end
end
