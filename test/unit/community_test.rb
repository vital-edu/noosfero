require File.dirname(__FILE__) + '/../test_helper'

class CommunityTest < Test::Unit::TestCase

  should 'inherit from Profile' do
    assert_kind_of Profile, Community.new
  end

  should 'convert name into identifier' do
    c = Community.new(:environment => Environment.default, :name =>'My shiny new Community')
    assert_equal 'My shiny new Community', c.name
    assert_equal 'my-shiny-new-community', c.identifier
  end

  should 'have a description attribute' do
    c = Community.new(:environment => Environment.default)
    c.description = 'the description of the community'
    assert_equal 'the description of the community', c.description
  end

  should 'create default set of blocks' do
    c = Community.create!(:environment => Environment.default, :name => 'my new community')

    assert c.boxes[0].blocks.map(&:class).include?(MainBlock)

    assert c.boxes[1].blocks.map(&:class).include?(ProfileInfoBlock)
    assert c.boxes[1].blocks.map(&:class).include?(RecentDocumentsBlock)

    assert c.boxes[2].blocks.map(&:class).include?(MembersBlock)
    assert c.boxes[2].blocks.map(&:class).include?(TagsBlock)

    assert_equal 5,  c.blocks.size
  end

  should 'get a default home page and RSS feed' do
    community = Community.create!(:environment => Environment.default, :name => 'my new community')

    assert_kind_of Article, community.home_page
    assert_kind_of RssFeed, community.articles.find_by_path('feed')
  end

  should 'have contact_person' do
    community = Community.new(:environment => Environment.default, :name => 'my new community')
    assert_respond_to community, :contact_person
  end

  should 'allow to add new members' do
    c = Community.create!(:environment => Environment.default, :name => 'my test profile', :identifier => 'mytestprofile')
    p = create_user('mytestuser').person

    c.add_member(p)

    assert c.members.include?(p), "Community should add the new member"
  end

  should 'allow to remove members' do
    c = Community.create!(:environment => Environment.default, :name => 'my other test profile', :identifier => 'myothertestprofile')
    p = create_user('myothertestuser').person

    c.add_member(p)
    assert_includes c.members, p
    c.remove_member(p)
    c.reload
    assert_not_includes c.members, p
  end

  should 'clear relationships after destroy' do
    c = Community.create!(:environment => Environment.default, :name => 'my test profile', :identifier => 'mytestprofile')
    member = create_user('memberuser').person
    admin = create_user('adminuser').person
    moderator = create_user('moderatoruser').person

    c.add_member(member)
    c.add_admin(admin)
    c.add_moderator(moderator)

    relationships = c.role_assignments
    assert_not_nil relationships

    c.destroy
    relationships.each do |i|
      assert !RoleAssignment.exists?(i.id)
    end
  end

  should 'have a community template' do
    env = Environment.create!(:name => 'test env')
    p = Community.create!(:environment => Environment.default, :name => 'test_com', :identifier => 'test_com', :environment => env)
    assert_kind_of Community, p.template
  end

  should 'return active_community_fields' do
    e = Environment.default
    e.expects(:active_community_fields).returns(['contact_phone', 'contact_email']).at_least_once
    ent = Community.new(:environment => e)

    assert_equal e.active_community_fields, ent.active_fields
  end

  should 'return required_community_fields' do
    e = Environment.default
    e.expects(:required_community_fields).returns(['contact_phone', 'contact_email']).at_least_once
    community = Community.new(:environment => e)

    assert_equal e.required_community_fields, community.required_fields
  end

  should 'require fields if community needs' do
    e = Environment.default
    e.expects(:required_community_fields).returns(['contact_phone']).at_least_once
    community = Community.new(:environment => e)
    assert ! community.valid?
    assert community.errors.invalid?(:contact_phone)

    community.contact_phone = '99999'
    community.valid?
    assert ! community.errors.invalid?(:contact_phone)
  end

end
