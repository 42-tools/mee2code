require 'test_helper'

class ClustersControllerTest < ActionController::TestCase
  test "user can see home page after sign in" do
    sign_in users(:user_1)
    get :index
    assert_response :success
  end

  test "user can not see home page without sign in or bypass ip" do
    get :index
    assert_redirected_to user_session_path
  end

  test "user can see home page with bypass ip" do
    request.remote_ip = '::1'
    get :index
    assert_response :success
  end
end
