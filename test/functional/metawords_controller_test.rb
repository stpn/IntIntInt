require 'test_helper'

class MetawordsControllerTest < ActionController::TestCase
  setup do
    @metaword = metawords(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:metawords)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create metaword" do
    assert_difference('Metaword.count') do
      post :create, metaword: @metaword.attributes
    end

    assert_redirected_to metaword_path(assigns(:metaword))
  end

  test "should show metaword" do
    get :show, id: @metaword.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @metaword.to_param
    assert_response :success
  end

  test "should update metaword" do
    put :update, id: @metaword.to_param, metaword: @metaword.attributes
    assert_redirected_to metaword_path(assigns(:metaword))
  end

  test "should destroy metaword" do
    assert_difference('Metaword.count', -1) do
      delete :destroy, id: @metaword.to_param
    end

    assert_redirected_to metawords_path
  end
end
