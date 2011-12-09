require 'test_helper'

class CorpusCommentsControllerTest < ActionController::TestCase
  setup do
    @corpus_comment = corpus_comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:corpus_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create corpus_comment" do
    assert_difference('CorpusComment.count') do
      post :create, corpus_comment: @corpus_comment.attributes
    end

    assert_redirected_to corpus_comment_path(assigns(:corpus_comment))
  end

  test "should show corpus_comment" do
    get :show, id: @corpus_comment.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @corpus_comment.to_param
    assert_response :success
  end

  test "should update corpus_comment" do
    put :update, id: @corpus_comment.to_param, corpus_comment: @corpus_comment.attributes
    assert_redirected_to corpus_comment_path(assigns(:corpus_comment))
  end

  test "should destroy corpus_comment" do
    assert_difference('CorpusComment.count', -1) do
      delete :destroy, id: @corpus_comment.to_param
    end

    assert_redirected_to corpus_comments_path
  end
end
