# encoding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper
  include AnswersHelper
  include SessionsHelper
  include LatexHelper
  include DotHelper
  include EnrollmentKeyHelper
  include CacheTools
  
  before_action :set_csp

  def set_csp
    mathjax      = "https://cdnjs.cloudflare.com"
    fontFileURL  = "https://themes.googleusercontent.com"
    fontStyleURL = "https://fonts.googleapis.com"
    xkcdComicURL = "https://imgs.xkcd.com"
    response.headers['Content-Security-Policy-Report-Only'] = [
      "default-src  'self'",
      "script-src   'self' 'unsafe-eval' #{mathjax}",
      "img-src      'self' data: #{mathjax} #{xkcdComicURL}",
      "style-src    'self' #{fontStyleURL}",
      "font-src     'self' #{fontFileURL}"
    ].join("; ")
  end

  def def_etag
    fresh_when(etag: etag)
  end
end
