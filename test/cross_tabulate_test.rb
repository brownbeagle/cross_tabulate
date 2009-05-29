require 'test_helper'

class CrossTabulateTest < ActiveSupport::TestCase
  # THESE WERE RIPPED OUT FROM THE ORIGINAL MODIFICATIONS TO RAILS CORE. THEY WON'T WORK HERE.
  def test_basic_cross
    cross = Comment.cross('post_id')
    assert_equal [{"7"=>"1", "1"=>"2", "2"=>"1", "4"=>"4", "5"=>"2"}], cross
  end

  def test_cross_with_sum_aggregator
    cross = Comment.cross('post_id', :aggregator => 'sum', :aggregator_column => 'id')
    assert_equal [{"7"=>"11", "1"=>"3", "2"=>"3", "4"=>"26", "5"=>"19"}], cross
  end

  def test_cross_with_joins
    cross = Comment.cross('posts.title', :joins => 'INNER JOIN posts ON comments.post_id = posts.id')
    assert_equal [{"sti comments"=>"4", "So I was thinking"=>"1", "eager loading with OR'd conditions"=>"1", "Welcome to the weblog"=>"2", "sti me"=>"2"}], cross
  end

  def test_cross_with_joins_and_group_and_aggregator
    # "Show me the number of comments an author receives based on post type"
    cross = Comment.cross('posts.type', :joins => 'INNER JOIN posts ON comments.post_id = posts.id', :group => 'posts.author_id', :aggregator_column => 'comments.id')
    assert_equal(
      [{"Post"=>"6", "SpecialPost"=>"1", "StiPost"=>"2", "author_id"=>"1"},
       {"Post"=>"1", "SpecialPost"=>"0", "StiPost"=>"0", "author_id"=>"2"}],
      cross)
  end
end
