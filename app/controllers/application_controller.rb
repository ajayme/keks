# encoding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include SessionsHelper
  include LatexHelper
  include DotHelper
  include JsonHelper
end
