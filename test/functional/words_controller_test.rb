require 'test_helper'

class WordsControllerTest < ActionController::TestCase
  setup do
    @word = words(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:words)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create word" do
    assert_difference('Word.count') do
      post :create, word: @word.attributes
    end

    assert_redirected_to word_path(assigns(:word))
  end

  test "should show word" do
    get :show, id: @word.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @word.to_param
    assert_response :success
  end

  test "should update word" do
    put :update, id: @word.to_param, word: @word.attributes
    assert_redirected_to word_path(assigns(:word))
  end

  test "should destroy word" do
    assert_difference('Word.count', -1) do
      delete :destroy, id: @word.to_param
    end

    assert_redirected_to words_path
  end
end
