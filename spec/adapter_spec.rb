require 'spec_helper'

require 'models/simple_article'

describe 'Adapter' do
  before(:all) do
    CreateArticles.up
    @adapter = Article.connection
  end

  it '#adapter_name' do
    @adapter.adapter_name.should eq('Teradata')
  end

  it '#supports_migrations?' do
    @adapter.supports_migrations?.should be_true
  end

  it '#native_database_types' do
    @adapter.native_database_types.count.should > 0
  end
  
  it '#database_name' do
    @adapter.database_name.should == 'weblog_development'
  end

  it '#active?' do
    @adapter.active?.should be_true
  end

  it '#exec_query' do
    article_1 = Article.create(:title => 'exec_query_1', :body => 'exec_query_1')
    article_2 = Article.create(:title => 'exec_query_2', :body => 'exec_query_2')
    articles = @adapter.exec_query('select * from articles')
    
    articles.select { |i| i['title'] == article_1.title }.first.should_not be_nil
    articles.select { |i| i['title'] == article_2.title }.first.should_not be_nil
  end

  it '#last_insert_id(table)' do
    article_1 = Article.create(:title => 'exec_query_1', :body => 'exec_query_1')
    article_1.id.should eq(@adapter.last_insert_id('articles'))

    article_2 = Article.create(:title => 'exec_query_2', :body => 'exec_query_2')
    
    article_1.id.should_not eq(article_2.id)

    article_2.id.should eq(@adapter.last_insert_id('articles'))
  end

  it '#tables' do
    @adapter.tables.should include('articles')
  end

  it '#table_exists?' do
    @adapter.table_exists?('articles').should be_true
  end

  it '#indexes' do
    id_index = @adapter.indexes('articles').first
    id_index.table.should eq('articles')
    id_index.name.should == ""
    id_index.unique.should be_true
    id_index.columns.should eq([ 'id' ])
  end

  it '#pk_and_sequence_for' do
    @adapter.pk_and_sequence_for('articles').should eq(['id', nil])
  end

  it '#primary_key' do
    @adapter.primary_key('articles').should eq('id')
  end

  after(:all) do
    CreateArticles.down
  end
end
