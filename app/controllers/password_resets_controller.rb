# encoding: utf-8

class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_mail(params[:mail].downcase)
    if user && !user.mail.blank?
      user.send_password_reset
      redirect_to root_url, :notice => "Eine E-Mail mit weiteren Instruktionen wurde gesendet. Wende Dich an eine in der Hilfe aufgelistete Person, wenn sie innerhalb einer Stunde nicht angekommen ist. Prüfe ggf. vorher Deinen Spam-Filter."
    else
      flash[:error] = "Diese E-Mail ist nicht bekannt. Tippfehler?"
      render 'new'
    end
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => "Dieser Passwort-zurücksetzen Link ist abgelaufen. Bitte versuche es erneut."
    elsif @user.update_attributes(params[:user])
      redirect_to signin_path, :notice => "Das Passwort wurde geändert."
    else
      render :edit
    end
  end
end
