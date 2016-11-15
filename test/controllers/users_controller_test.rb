require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "user can see histories page after sign in" do
    sign_in users(:user_1)
    get :histories
    assert_response :success
  end

  test "user can not see histories page without login and bypass ip" do
    get :histories
    assert_redirected_to user_session_path
  end

  test "user can not see histories page with bypass ip" do
    request.remote_ip = '::1'
    get :histories
    assert_redirected_to user_session_path
  end
end
