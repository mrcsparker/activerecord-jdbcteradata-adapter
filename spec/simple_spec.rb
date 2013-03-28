require 'spec_helper'

require 'models/simple_article'

describe 'SimpleSpec' do
  it 'should be able to create and destroy a table' do
    CreateArticles.up
    article = Article.new
    article.title = 'Sample title'
    article.body = 'Sample body'
    article.save.should be_true
    CreateArticles.down
  end

  context 'basic activerecord functionality' do
    before(:all) do
      CreateArticles.up
    end
    
    it 'should autoincrement the `id` field' do
      Article.create(:title => 'auto_first', :body => 'auto_first')
      Article.create(:title => 'auto_second', :body => 'auto_second')
      articles = Article.all
      first = articles.select { |a| a.title == 'auto_first' }.first
      second = articles.select { |a| a.title == 'auto_second' }.first
      first.id.should_not eq(second.id)
    end

    it 'should populate the `created_at` field' do
      article = Article.create(:title => 'created_at test', :body => 'created_at test')
      article.created_at.should_not be_nil
    end

    it 'should populate the `updated_at` field' do
      article = Article.create(:title => 'created_at test', :body => 'created_at test')
      article.updated_at.should_not be_nil
    end

    it 'should be able to find(:where) an item' do
      article = Article.create(:title => 'reload', :body => 'reload')
      article = Article.where(:title => 'reload').first
      article.title.should eq('reload')
    end

    it 'should be able to #reload and item' do
      
    end

    after(:all) do
      CreateArticles.down
    end
  end
end
