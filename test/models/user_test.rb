require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'Example User', email: 'user@example.com',
                     password: 'foobar', password_confirmation: 'foobar')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = '  '
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = '  '
    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test 'email should not be too long' do
    @user.name = 'a' * 256
    assert_not @user.valid?
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.Com user@foo.com a_us-er@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]

    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?
    end
  end

  test 'email address should be unqiue' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'passwrod should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test 'authenticated? should return false for a user with nil digest' do
    assert_not @user.authenticated?(:remember, '')
  end

  test 'associated microposts should be destroyed' do
    @user.save
    @user.microposts.create!(content: 'test test')
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test 'should follow and unfollow a user' do
    eric = users(:eric)
    malory = users(:malory)
    assert_not eric.following?(malory)
    eric.follow(malory)
    assert eric.following?(malory)
    assert malory.followers.include?(eric)
    eric.unfollow(malory)
    assert_not eric.following?(malory)
  end

  test 'feed should have the right posts' do
    eric = users(:eric)
    malory = users(:malory)
    lana = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert eric.feed.include?(post_following)
    end
    # Posts from self
    eric.microposts.each do |post_self|
      assert eric.feed.include?(post_self)
    end
    # Posts from unfollowed user
    malory.microposts.each do |post_unfollowed|
      assert_not eric.feed.include?(post_unfollowed)
    end
  end
end
