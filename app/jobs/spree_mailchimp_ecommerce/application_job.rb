module SpreeMailchimpEcommerce
  class ApplicationJob < ActiveJob::Base
    around_perform do |job, block|
      store_id = job.arguments[0]["store_id"] rescue nil
      block.call if ready_for_mailchimp?(store_id) || job.class == SpreeMailchimpEcommerce::CreateStoreJob
    end

    private

    def ready_for_mailchimp?(store_id)
      [
        mailchimp_api_key(store_id),
        mailchimp_store_id(store_id),
        mailchimp_list_id(store_id),
        mailchimp_store_name(store_id),
        cart_url(store_id)
      ].map(&:nil?).none?
    end

    def mailchimp_api_key(store_id)
      ::SpreeMailchimpEcommerce.configuration(store_id).mailchimp_api_key
    end

    def mailchimp_store_id(store_id)
      ::SpreeMailchimpEcommerce.configuration(store_id).mailchimp_store_id
    end

    def mailchimp_list_id(store_id)
      ::SpreeMailchimpEcommerce.configuration(store_id).mailchimp_list_id
    end

    def mailchimp_store_name(store_id)
      ::SpreeMailchimpEcommerce.configuration(store_id).mailchimp_store_name
    end

    def cart_url(store_id)
      ::SpreeMailchimpEcommerce.configuration(store_id).cart_url
    end

    def gibbon_store(store_id)
      ::Gibbon::Request.new(api_key: mailchimp_api_key(store_id)).
        ecommerce.stores(mailchimp_store_id(store_id))
    end

    def list(store_id)
      ::Gibbon::Request.new(api_key: mailchimp_api_key(store_id)).lists(mailchimp_list_id(store_id))
    end

    def member(store_id, user_id)
      list(store_id).members(user_id)
    end
  end
end
