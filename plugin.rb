# name: force_http_language_header
# about: Force UI Language to be set by browser language header.
# version: 0.1.1
# authors: wfjsw
# url: https://github.com/wfjsw/discourse-force-http-language

enabled_site_setting :force_http_language_header

gem 'http_accept_language', '2.0.5'

require 'current_user'

after_initialize do

  ApplicationController.class_eval do
    def set_locale
      if SiteSetting.force_http_language_header
        locale = locale_from_header
      else
        if !current_user
          if SiteSetting.set_locale_from_accept_language_header
            locale = locale_from_header
          else
            locale = SiteSetting.default_locale
          end
        else
          locale = current_user.effective_locale
        end
      end

      I18n.locale = I18n.locale_available?(locale) ? locale : SiteSettings::DefaultsProvider::DEFAULT_LOCALE
      I18n.ensure_all_loaded!
    end
  end
end
