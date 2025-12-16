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
      if SiteSetting.force_http_language_header
        locale = HttpLanguageParser.parse(request.env["HTTP_ACCEPT_LANGUAGE"])
      else
        if check_current_user &&
            (
              user =
                begin
                  current_user
                rescue StandardError
                  nil
                end
            )
          locale = user.effective_locale
        else
          locale = Discourse.anonymous_locale(request)
          locale ||= SiteSetting.default_locale
          persist_locale_param_to_cookie
        end
      end
      locale = SiteSettings::DefaultsProvider::DEFAULT_LOCALE if !I18n.locale_available?(locale)

      I18n.ensure_all_loaded!
      I18n.with_locale(locale) { yield }
    end
  end
end
