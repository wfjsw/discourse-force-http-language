# name: force_http_language_header
# about: Force UI Language to be set by browser language header.
# version: 2.0.0
# authors: wfjsw
# url: https://github.com/wfjsw/discourse-force-http-language

enabled_site_setting :force_http_language_header

require 'current_user'

after_initialize do

  ApplicationController.class_eval do
    def with_resolved_locale(check_current_user: true)
      locale_from_header = HttpLanguageParser.parse(request.env["HTTP_ACCEPT_LANGUAGE"])
      if SiteSetting.force_http_language_header
        locale = locale_from_header
      else
        if check_current_user && (user = current_user rescue nil)
          locale = user.effective_locale
        else
          locale = Discourse.anonymous_locale(request)
          locale ||= SiteSetting.default_locale
        end
      end
      if !I18n.locale_available?(locale)
        locale = SiteSettings::DefaultsProvider::DEFAULT_LOCALE
      end
      I18n.ensure_all_loaded!
      I18n.with_locale(locale) { yield }
    end
  end
end
