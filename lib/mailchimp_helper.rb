module MailchimpHelper
  class << self
    def mailchimp_snippet
      set_snippet&.html_safe
    end

    private

    def set_snippet
      return unless mailchimp_store_id && ::SpreeMailchimpEcommerce.configuration(nil).mailchimp_api_key

      begin
        Rails.cache.fetch "mailchimp_settings_#{mailchimp_store_id}" do
          ::Gibbon::Request.new(api_key: ::SpreeMailchimpEcommerce.configuration(nil).mailchimp_api_key).
            ecommerce.stores(mailchimp_store_id).retrieve.body["connected_site"]["site_script"]["fragment"]
        end
      rescue Gibbon::MailChimpError => e
        Rails.logger.error("[MAILCHIMP] error on retrieving snippet #{e}")
        ""
      end
    end

    def mailchimp_store_id
      ::SpreeMailchimpEcommerce.configuration(nil).mailchimp_store_id
    end
  end
end
