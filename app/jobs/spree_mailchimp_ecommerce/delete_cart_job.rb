# frozen_string_literal: true

module SpreeMailchimpEcommerce
  class DeleteCartJob < ApplicationJob
    def perform(order)
      gibbon_store(order.store_id).carts(order.number).delete
    end
  end
end
