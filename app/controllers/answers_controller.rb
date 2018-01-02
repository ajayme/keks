# encoding: utf-8

class AnswersController < ApplicationController
  before_action :require_admin
  before_action :get_question

  include DefaultActionsHelper

  private
  def params_answers
    params.require(:answers).permit(:correct, :text)
  end
end
