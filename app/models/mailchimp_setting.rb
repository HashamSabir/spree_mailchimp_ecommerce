class MailchimpSetting < ActiveRecord::Base
  before_save :set_cart_url
  validates :mailchimp_api_key, :mailchimp_store_id, :mailchimp_list_id, :mailchimp_store_name, :cart_url, presence: true
  validate :validate_only_one_store, on: :create
  validate :ensure_store_id

  belongs_to :store, class_name: "Spree::Store", optional: true
  attr_accessor :multi_store

  def validate_only_one_store
    # errors.add(:base, "only one store allowed") unless MailchimpSetting.count.zero?
    errors.add(:base, "only one store allowed") if MailchimpSetting.where(store_id: self.store_id).present?
  end

  def already_exist?
    attrs = self.attributes.slice("mailchimp_api_key", "mailchimp_list_id", "mailchimp_store_name")
    other_settings = MailchimpSetting.where(attrs)
    other_settings = other_settings - [self]
    other_settings.any?
  end

  def create_store_id
    Digest::MD5.hexdigest(mailchimp_store_name + mailchimp_list_id).to_s
  end

  def accout_name
    ::SpreeMailchimpEcommerce::GetAccountNameJob.perform_now(self)
  end

  def set_cart_url
    self.cart_url = "#{domain_url}/cart" unless multi_store
    self.cart_url = "#{self.store.domain_url}/cart" if multi_store
  end

  def ensure_store_id
    return true unless multi_store
    errors.add(:base, "Store can not be blank") unless store_id.present?
  end

  def domain_url
    url = ENV['FRONT_END_APP_URL']
    return url unless url["http://"].nil? && url["https://"].nil?
    "https://#{url}"
  end
end
