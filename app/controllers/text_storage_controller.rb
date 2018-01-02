# encoding: utf-8

class TextStorageController < ApplicationController
  before_action :require_admin

  def update
    @message = (TextStorage.find(params[:id])) rescue nil

    if @message && @message.update_attributes(params_text_storage)
      flash[:success] = "Mitteilung aktualisiert"
      redirect_back(fallback_location: reviews_path)
    else
      redirect_back(fallback_location: reviews_path)
    end
  end

  private
  def params_text_storage
    params.require(:text_storage).permit(:ident, :value)
  end
end
