require 'test_helper'

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get root" do
    get root_url
    assert_response :success
  end

  test "should get overview" do
    get main_overview_url
    assert_response :success
  end

  test "should get help" do
    get main_help_url
    assert_response :success
  end

  test "should get feedback" do
    get main_feedback_url
    assert_response :success
  end

  # test "should get feedback_send" do
  #   get main_feedback_send_url
  #   assert_response :success
  # end

  test "should get hitme" do
    get main_hitme_url
    assert_response :success
  end
end
