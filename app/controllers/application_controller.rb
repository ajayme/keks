# encoding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include AnswersHelper
  include SessionsHelper
  include LatexHelper
  include DotHelper
  include JsonHelper

  before_filter :init
  before_filter :set_csp

  def init
    @start_time = Time.now.usec
  end

  def set_csp
    mathjax      = "https://c328740.ssl.cf1.rackcdn.com"
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
end
