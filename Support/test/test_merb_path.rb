require File.dirname(__FILE__) + '/test_helper'

require 'text_mate_mock'
require 'merb/merb_path'

class TestMerbPath < Test::Unit::TestCase
  def setup
    TextMate.line_number = '1'
    TextMate.column_number = '1'
    TextMate.project_directory = File.expand_path(File.dirname(__FILE__) + '/app_fixtures')
    @rp_controller = MerbPath.new(FIXTURE_PATH + '/app/controllers/users.rb')
    @rp_controller_with_module = MerbPath.new(FIXTURE_PATH + '/app/controllers/admin/posts.rb')
    @rp_view = MerbPath.new(FIXTURE_PATH + '/app/views/user/new.html.erb')
    @rp_view_with_module = MerbPath.new(FIXTURE_PATH + '/app/views/admin/posts/action.html.erb')
  end

  def test_merb_root
    assert_equal File.expand_path(File.dirname(__FILE__) + '/app_fixtures'), MerbPath.new.merb_root
  end

  def test_extension
    assert_equal "rb", @rp_controller.extension
    assert_equal "erb", @rp_view.extension
  end

  def test_file_type
    assert_equal :controller, @rp_controller.file_type
    assert_equal :view, @rp_view.file_type
  end

  def test_modules
    assert_equal [], @rp_controller.modules
    assert_equal ['admin'], @rp_controller_with_module.modules
    assert_equal [], @rp_view.modules
    assert_equal ['admin'], @rp_view_with_module.modules
  end

  def test_controller_name
    rp = MerbPath.new(FIXTURE_PATH + '/app/models/person.rb')
    assert_equal "people", rp.controller_name
    rp = MerbPath.new(FIXTURE_PATH + '/app/models/user.rb')
    assert_equal "users", rp.controller_name
    rp = MerbPath.new(FIXTURE_PATH + '/app/models/users.rb')
    assert_equal "users", rp.controller_name
  end

  def test_file_parts
    current_file = MerbPath.new(FIXTURE_PATH + '/app/views/users/new.html.erb')
    assert_equal(FIXTURE_PATH + '/app/views/users/new.html.erb', current_file.filepath)
    pathname, basename, content_type, extension = current_file.parse_file_parts
    assert_equal(FIXTURE_PATH + '/app/views/users', pathname)
    assert_equal('new', basename)
    assert_equal('html', content_type)
    assert_equal('erb', extension)

    current_file = MerbPath.new(FIXTURE_PATH + '/app/views/user/new.rhtml')
    pathname, basename, content_type, extension = current_file.parse_file_parts
    assert_equal(FIXTURE_PATH + '/app/views/user', pathname)
    assert_equal('new', basename)
    assert_equal(nil, content_type)
    assert_equal('rhtml', extension)
  end

  def test_new_merb_path_has_parts
    current_file = MerbPath.new(FIXTURE_PATH + '/app/views/users/new.html.erb')
    assert_equal(FIXTURE_PATH + '/app/views/users/new.html.erb', current_file.filepath)
    assert_equal(FIXTURE_PATH + '/app/views/users', current_file.path_name)
    assert_equal('new', current_file.file_name)
    assert_equal('html', current_file.content_type)
    assert_equal('erb', current_file.extension)
  end


  def test_controller_name_and_action_name_for_controller
    rp = MerbPath.new(FIXTURE_PATH + '/app/controllers/users.rb')
    assert_equal "users", rp.controller_name
    assert_equal nil, rp.action_name

    TextMate.line_number = '3'
    rp = MerbPath.new(FIXTURE_PATH + '/app/controllers/users.rb')
    assert_equal "users", rp.controller_name
    assert_equal "new", rp.action_name

    TextMate.line_number = '7'
    rp = MerbPath.new(FIXTURE_PATH + '/app/controllers/users.rb')
    assert_equal "users", rp.controller_name
    assert_equal "create", rp.action_name
  end

  def test_controller_name_and_action_name_for_view
    rp = MerbPath.new(FIXTURE_PATH + '/app/views/users/new.html.erb')
    assert_equal "users", rp.controller_name
    assert_equal "new", rp.action_name
  end

  def test_controller_name_pluralization
    rp = MerbPath.new(FIXTURE_PATH + '/app/views/people/new.html.erb')
    assert_equal "people", rp.controller_name
  end

  def test_controller_name_suggestion_when_controller_absent
    rp = MerbPath.new(FIXTURE_PATH + '/app/views/people/new.html.erb')
    assert_equal "people", rp.controller_name
  end
  
  def test_merb_path_for
    partners = [
      # Basic tests
      [FIXTURE_PATH + '/app/controllers/users.rb', :helper, FIXTURE_PATH + '/app/helpers/users_helper.rb'],
      [FIXTURE_PATH + '/app/controllers/users.rb', :javascript, FIXTURE_PATH + '/public/javascripts/users.js'],
      [FIXTURE_PATH + '/app/controllers/users.rb', :functional_test, FIXTURE_PATH + '/test/functional/users_test.rb'],
      [FIXTURE_PATH + '/app/helpers/users_helper.rb', :controller, FIXTURE_PATH + '/app/controllers/users.rb'],
      [FIXTURE_PATH + '/app/models/user.rb', :controller, FIXTURE_PATH + '/app/controllers/users.rb'],
      [FIXTURE_PATH + '/app/models/post.rb', :controller, FIXTURE_PATH + '/app/controllers/posts.rb'],
      # [FIXTURE_PATH + '/test/fixtures/users.yml', :model, FIXTURE_PATH + '/app/models/user.rb'],
      # [FIXTURE_PATH + '/spec/fixtures/users.yml', :model, FIXTURE_PATH + '/app/models/user.rb'],
      [FIXTURE_PATH + '/app/controllers/users.rb', :model, FIXTURE_PATH + '/app/models/user.rb'],
      # [FIXTURE_PATH + '/test/fixtures/users.yml', :unit_test, FIXTURE_PATH + '/test/unit/user_test.rb'],
      # [FIXTURE_PATH + '/app/models/user.rb', :fixture, FIXTURE_PATH + '/test/fixtures/users.yml'],
      # With modules
      [FIXTURE_PATH + '/app/controllers/admin/bases.rb', :helper, FIXTURE_PATH + '/app/helpers/admin/bases_helper.rb'],
      [FIXTURE_PATH + '/app/controllers/admin/inside/outside.rb', :javascript, FIXTURE_PATH + '/public/javascripts/admin/inside/outside.js'],
      [FIXTURE_PATH + '/app/controllers/admin/bases.rb', :functional_test, FIXTURE_PATH + '/test/functional/admin/bases_test.rb'],
      [FIXTURE_PATH + '/app/helpers/admin/base_helper.rb', :controller, FIXTURE_PATH + '/app/controllers/admin/bases.rb'],
    ]
    for pair in partners
      assert_equal MerbPath.new(pair[2]), MerbPath.new(pair[0]).merb_path_for(pair[1]), pair.inspect
    end
  
    # Test controller to view
    ENV['RAILS_VIEW_EXT'] = nil
    TextMate.line_number = '8'
    current_file = MerbPath.new(FIXTURE_PATH + '/app/controllers/users.rb')
    assert_equal MerbPath.new(FIXTURE_PATH + '/app/views/users/create.html.erb'), current_file.merb_path_for(:view)
  
    # 2.0 plural controllers
    current_file = MerbPath.new(FIXTURE_PATH + '/app/controllers/users.rb')
    assert_equal MerbPath.new(FIXTURE_PATH + '/app/views/users/create.html.erb'), current_file.merb_path_for(:view)
  
    TextMate.line_number = '3'
    current_file = MerbPath.new(FIXTURE_PATH + '/app/controllers/users.rb')
    assert_equal MerbPath.new(FIXTURE_PATH + '/app/views/users/new.html.erb'), current_file.merb_path_for(:view)
  
    # 2.0 plural controllers
    current_file = MerbPath.new(FIXTURE_PATH + '/app/controllers/users.rb')
    assert_equal MerbPath.new(FIXTURE_PATH + '/app/views/users/new.html.erb'), current_file.merb_path_for(:view)
  
    # Test view to controller
    current_file = MerbPath.new(FIXTURE_PATH + '/app/views/user/new.html.erb')
    assert_equal MerbPath.new(FIXTURE_PATH + '/app/controllers/users.rb'), current_file.merb_path_for(:controller)
  
    # 2.0 plural controllers
    current_file = MerbPath.new(FIXTURE_PATH + '/app/views/users/new.html.erb')
    assert_equal MerbPath.new(FIXTURE_PATH + '/app/controllers/users.rb'), current_file.merb_path_for(:controller)
  
  end
  
  def test_best_match
    assert_equal(nil, MerbPath.new(FIXTURE_PATH + '/config/init.rb').best_match)
    assert_equal(:functional_test, MerbPath.new(FIXTURE_PATH + '/app/controllers/posts.rb').best_match)

    TextMate.line_number = '3' # new action
    assert_equal(:view, MerbPath.new(FIXTURE_PATH + '/app/controllers/users.rb').best_match)
    TextMate.line_number = '0'

    assert_equal(:controller, MerbPath.new(FIXTURE_PATH + '/app/views/users/new.html.erb').best_match)
    assert_equal(:controller, MerbPath.new(FIXTURE_PATH + '/app/views/admin/base/action.html.erb').best_match)
    assert_equal(:controller, MerbPath.new(FIXTURE_PATH + '/app/views/notifier/forgot_password.html.erb').best_match)
    assert_equal(:controller, MerbPath.new(FIXTURE_PATH + '/app/views/books/new.haml').best_match)
  end
  #
  # def test_wants_haml
  #   begin
  #     assert_equal false, @rp_view.wants_haml
  #     haml_fixture_path = File.expand_path(File.dirname(__FILE__) + '/fixtures')
  #     TextMate.project_directory = haml_fixture_path
  #     assert_equal true, MerbPath.new(haml_fixture_path + '/app/views/posts/index.html.haml').wants_haml
  #   ensure
  #     TextMate.project_directory = File.expand_path(File.dirname(__FILE__) + '/app_fixtures')
  #   end
  # end
  #
  # def test_haml
  #   begin
  #     haml_fixture_path = File.expand_path(File.dirname(__FILE__) + '/fixtures')
  #     TextMate.project_directory = haml_fixture_path
  #
  #     assert_equal [], MerbPath.new(haml_fixture_path + '/public/stylesheets/sass/posts.sass').modules
  #     assert_equal ["admin"], MerbPath.new(haml_fixture_path + '/public/stylesheets/sass/admin/posts.sass').modules
  #
  #     # Going from controller to view
  #     current_file = MerbPath.new(haml_fixture_path + '/app/controllers/posts_controller.rb')
  #     TextMate.line_number = '2'
  #     assert_equal MerbPath.new(haml_fixture_path + '/app/views/posts/new.html.haml'), current_file.merb_path_for(:view)
  #
  #     current_file = MerbPath.new(haml_fixture_path + '/app/controllers/posts_controller.rb')
  #     TextMate.line_number = '12'
  #     assert_equal MerbPath.new(haml_fixture_path + '/app/views/posts/index.html.haml'), current_file.merb_path_for(:view)
  #
  #     current_file = MerbPath.new(haml_fixture_path + '/app/controllers/posts_controller.rb')
  #     TextMate.line_number = '13'
  #     assert_equal MerbPath.new(haml_fixture_path + '/app/views/posts/index.xml.builder'), current_file.merb_path_for(:view)
  #
  #     current_file = MerbPath.new(haml_fixture_path + '/app/controllers/posts_controller.rb')
  #     TextMate.line_number = '14'
  #     assert_equal MerbPath.new(haml_fixture_path + '/app/views/posts/index.js.rjs'), current_file.merb_path_for(:view)
  #
  #     current_file = MerbPath.new(haml_fixture_path + '/app/controllers/posts_controller.rb')
  #     TextMate.line_number = '15'
  #     assert_equal MerbPath.new(haml_fixture_path + '/app/views/posts/index.wacky.haml'), current_file.merb_path_for(:view)
  #
  #     # Going from view to controller
  #     current_file = MerbPath.new(haml_fixture_path + '/app/views/posts/index.html.haml')
  #     assert_equal MerbPath.new(haml_fixture_path + '/app/controllers/posts_controller.rb'), current_file.merb_path_for(:controller)
  #
  #     # Going from view to stylesheet
  #     current_file = MerbPath.new(haml_fixture_path + '/app/views/posts/index.html.haml')
  #     assert_equal MerbPath.new(haml_fixture_path + '/public/stylesheets/sass/posts.sass'), current_file.merb_path_for(:stylesheet)
  #
  #     # Going from stylesheet to helper
  #     current_file = MerbPath.new(haml_fixture_path + '/public/stylesheets/sass/posts.sass')
  #     assert_equal MerbPath.new(haml_fixture_path + '/app/helpers/posts_helper.rb'), current_file.merb_path_for(:helper)
  #
  #   ensure
  #     TextMate.project_directory = File.expand_path(File.dirname(__FILE__) + '/app_fixtures')
  #   end
  # end

end