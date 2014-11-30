require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AppBox
  class Application < Rails::Application
    config.generators.template_engine = :slim
    config.active_record.default_timezone :local
  end
end
