# frozen_string_literal: true
def page_title
  [content_for(:page_title) || content_for(:thredded_page_title),
   t('brand.name')].compact.join(' - ')
end

# @param datetime [DateTime]
# @param default [String] a string to return if time is nil.
# @return [String] html_safe datetime presentation
def time_ago(datetime, default: '-')
  timeago_tag datetime,
              lang:    I18n.locale.to_s.downcase,
              format:  (lambda do |t, _opts|
                t.year == Time.current.year ? :short : :long
              end),
              nojs:    true,
              default: default
end
