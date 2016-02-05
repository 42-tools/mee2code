require 'test_helper'

class ClustersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "user can see home page after login" do
    sign_in users(:user_1)
    get :index
    assert_response :success
  end   

  test "user can not see home page without login" do
    get :index
    assert_redirected_to user_session_path
  end
end
