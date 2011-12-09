require 'test_helper'

class PhrasesControllerTest < ActionController::TestCase
  setup do
    @phrase = phrases(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:phrases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create phrase" do
    assert_difference('Phrase.count') do
      post :create, phrase: @phrase.attributes
    end

    assert_redirected_to phrase_path(assigns(:phrase))
  end

  test "should show phrase" do
    get :show, id: @phrase.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @phrase.to_param
    assert_response :success
  end

  test "should update phrase" do
    put :update, id: @phrase.to_param, phrase: @phrase.attributes
    assert_redirected_to phrase_path(assigns(:phrase))
  end

  test "should destroy phrase" do
    assert_difference('Phrase.count', -1) do
      delete :destroy, id: @phrase.to_param
    end

    assert_redirected_to phrases_path
  end
end
