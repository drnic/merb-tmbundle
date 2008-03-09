require File.join(File.dirname(__FILE__), "..",'test_helper')

# Re-raise errors caught by the controller.
class Users; def rescue_action(e) raise e end; end

class UsersTest < Test::Unit::TestCase

  def setup
    @controller = Users.build(fake_request)
    @controller.dispatch('index')
  end

  # Replace this with your real tests.
  def test_should_be_setup
    assert false
  end
end