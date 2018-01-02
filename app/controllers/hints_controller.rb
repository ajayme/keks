# encoding: utf-8

class HintsController < ApplicationController
  before_action :require_admin
  before_action :get_question

  include DefaultActionsHelper
end
