# name: force_http_language_header
# about: Force UI Language to be set by browser language header.
# version: 1.0.0
# authors: wfjsw
# url: https://github.com/wfjsw/discourse-force-http-language

enabled_site_setting :force_http_language_header

require 'current_user'

after_initialize do

  ApplicationController.class_eval do
    def with_resolved_locale(check_current_user: true)
      if SiteSetting.force_http_language_header
        locale = locale_from_header
      else
        if !current_user
          if SiteSetting.set_locale_from_accept_language_header
            locale = locale_from_header
          else
            locale = SiteSetting.default_locale
          end
        elsif check_current_user
          locale = current_user.effective_locale
        end
      end

      locale = I18n.locale_available?(locale) ? locale : SiteSettings::DefaultsProvider::DEFAULT_LOCALE
      
      I18n.ensure_all_loaded!
      I18n.with_locale(locale) { yield }
    end
  end
end
