class CreateActiveRecordSchema < ActiveRecord::Migration

  def self.up

    # ------------------------------------------------------------------- #
    #                                                                     #
    #   Please keep these create table statements in alphabetical order   #
    #   unless the ordering matters.  In which case, define them below.   #
    #                                                                     #
    # ------------------------------------------------------------------- #

    create_table :ar_accounts, :force => true do |t|
      t.integer :firm_id
      t.string  :firm_name
      t.integer :credit_limit
    end

    create_table :ar_admin_accounts, :force => true do |t|
      t.string :name
    end

    create_table :ar_admin_users, :force => true do |t|
      t.string :name
      t.string :settings, :null => true, :limit => 1024
      # MySQL does not allow default values for blobs. Fake it out with a
      # big varchar below.
      t.string :preferences, :null => true, :default => '', :limit => 1024
      t.references :account
    end

    create_table :ar_aircraft, :force => true do |t|
      t.string :name
    end

    create_table :ar_audit_logs, :force => true do |t|
      t.column :message, :string, :null=>false
      t.column :developer_id, :integer, :null=>false
      t.integer :unvalidated_developer_id
    end

    create_table :ar_authors, :force => true do |t|
      t.string :name, :null => false
      t.integer :author_address_id
      t.integer :author_address_extra_id
      t.string :organization_id
      t.string :owned_essay_id
    end

    create_table :ar_author_addresses, :force => true do |t|
    end

    create_table :ar_author_favorites, :force => true do |t|
      t.column :author_id, :integer
      t.column :favorite_author_id, :integer
    end

    create_table :ar_auto_id_tests, :force => true, :id => false do |t|
      t.primary_key :auto_id
      t.integer     :value
    end

    create_table :ar_binaries, :force => true do |t|
      t.string :name
      t.binary :data
      t.binary :short_data, :limit => 2048
    end

    create_table :ar_birds, :force => true do |t|
      t.string :name
      t.string :color
      t.integer :pirate_id
    end

    create_table :ar_books, :force => true do |t|
      t.integer :author_id
      t.column :name, :string
    end

    create_table :ar_booleans, :force => true do |t|
      t.boolean :value
      t.boolean :has_fun, :null => false, :default => false
    end

    create_table :ar_bulbs, :force => true do |t|
      t.integer :car_id
      t.string  :name
      t.boolean :frickinawesome
      t.string :color
    end

    create_table 'CamelCase', :force => true do |t|
      t.string :name
    end

    create_table :ar_cars, :force => true do |t|
      t.string  :name
      t.integer :engines_count
      t.integer :wheels_count
      t.timestamps
    end

    create_table :ar_categories, :force => true do |t|
      t.string :name, :null => false
      t.string :type
      t.integer :categorizations_count
    end

    create_table :ar_categories_posts, :force => true, :id => false do |t|
      t.integer :category_id, :null => false
      t.integer :post_id, :null => false
    end

    create_table :ar_categorizations, :force => true do |t|
      t.column :category_id, :integer
      t.string :named_category_name
      t.column :post_id, :integer
      t.column :author_id, :integer
      t.column :special, :boolean
    end

    create_table :ar_citations, :force => true do |t|
      t.column :book1_id, :integer
      t.column :book2_id, :integer
    end

    create_table :ar_clubs, :force => true do |t|
      t.string :name
      t.integer :category_id
    end

    create_table :ar_collections, :force => true do |t|
      t.string :name
    end

    create_table :ar_colnametests, :force => true do |t|
      t.integer :references, :null => false
    end

    create_table :ar_comments, :force => true do |t|
      t.integer :post_id, :null => false
      t.text    :body, :null => false
      t.string  :type
      t.integer :taggings_count, :default => 0
      t.integer :children_count, :default => 0
      t.integer :parent_id
    end

    create_table :ar_companies, :force => true do |t|
      t.string  :type
      t.string  :ruby_type
      t.integer :firm_id
      t.string  :firm_name
      t.string  :name
      t.integer :client_of
      t.integer :rating, :default => 1
      t.integer :account_id
      t.string :description, :default => ''
    end

    add_index :ar_companies, [:firm_id, :type, :rating, :ruby_type], :name => 'company_index'

    create_table :ar_vegetables, :force => true do |t|
      t.string :name
      t.string :custom_type
    end

    create_table :ar_computers, :force => true do |t|
      t.integer :developer, :null => false
      t.integer :extendedWarranty, :null => false
    end

    create_table :ar_contracts, :force => true do |t|
      t.integer :developer_id
      t.integer :company_id
    end

    create_table :ar_customers, :force => true do |t|
      t.string  :name
      t.integer :balance, :default => 0
      t.string  :address_street
      t.string  :address_city
      t.string  :address_country
      t.string  :gps_location
    end

    create_table :ar_dashboards, :force => true, :id => false do |t|
      t.string :dashboard_id
      t.string :name
    end

    create_table :ar_developers, :force => true do |t|
      t.string   :name
      t.integer  :salary, :default => 70000
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :ar_developers_projects, :force => true, :id => false do |t|
      t.integer :developer_id, :null => false
      t.integer :project_id, :null => false
      t.date    :joined_on
      t.integer :access_level, :default => 1
    end

    create_table :ar_dog_lovers, :force => true do |t|
      t.integer :trained_dogs_count, :default => 0
      t.integer :bred_dogs_count, :default => 0
    end

    create_table :ar_dogs, :force => true do |t|
      t.integer :trainer_id
      t.integer :breeder_id
    end

    create_table :ar_edges, :force => true, :id => false do |t|
      t.column :source_id, :integer, :null => false
      t.column :sink_id,   :integer, :null => false
    end
    add_index :ar_edges, [:source_id, :sink_id], :unique => true, :name => 'unique_edge_index'

    create_table :ar_engines, :force => true do |t|
      t.integer :car_id
    end

    create_table :ar_entrants, :force => true do |t|
      t.string  :name, :null => false
      t.integer :course_id, :null => false
    end

    create_table :ar_essays, :force => true do |t|
      t.string :name
      t.string :writer_id
      t.string :writer_type
      t.string :category_id
      t.string :author_id
    end

    create_table :ar_events, :force => true do |t|
      t.string :title, :limit => 5
    end

    create_table :ar_eyes, :force => true do |t|
    end

    create_table :ar_funny_jokes, :force => true do |t|
      t.string :name
    end

    create_table :ar_cold_jokes, :force => true do |t|
      t.string :name
    end

    create_table :ar_friendships, :force => true do |t|
      t.integer :friend_id
      t.integer :person_id
    end

    create_table :ar_goofy_string_id, :force => true, :id => false do |t|
      t.string :id, :null => false
      t.string :info
    end

    create_table :ar_having, :force => true do |t|
      t.string :where
    end

    create_table :ar_guids, :force => true do |t|
      t.column :key, :string
    end

    create_table :ar_inept_wizards, :force => true do |t|
      t.column :name, :string, :null => false
      t.column :city, :string, :null => false
      t.column :type, :string
    end

    create_table :ar_integer_limits, :force => true do |t|
      t.integer :'c_int_without_limit'
      (1..8).each do |i|
        t.integer :"c_int_#{i}", :limit => i
      end
    end

    create_table :ar_invoices, :force => true do |t|
      t.integer :balance
      t.datetime :updated_at
    end

    create_table :ar_iris, :force => true do |t|
      t.references :eye
      t.string     :color
    end

    create_table :ar_items, :force => true do |t|
      t.column :name, :string
    end

    create_table :ar_jobs, :force => true do |t|
      t.integer :ideal_reference_id
    end

    create_table :ar_keyboards, :force => true, :id  => false do |t|
      t.primary_key :key_number
      t.string      :name
    end

    create_table :ar_legacy_things, :force => true do |t|
      t.integer :tps_report_number
      t.integer :version, :null => false, :default => 0
    end

    create_table :ar_lessons, :force => true do |t|
      t.string :name
    end

    create_table :ar_lessons_students, :id => false, :force => true do |t|
      t.references :lesson
      t.references :student
    end

    create_table :ar_lint_models, :force => true

    create_table :ar_line_items, :force => true do |t|
      t.integer :invoice_id
      t.integer :amount
    end

    create_table :ar_lock_without_defaults, :force => true do |t|
      t.column :lock_version, :integer
    end

    create_table :ar_lock_without_defaults_cust, :force => true do |t|
      t.column :custom_lock_version, :integer
    end

    create_table :ar_mateys, :id => false, :force => true do |t|
      t.column :pirate_id, :integer
      t.column :target_id, :integer
      t.column :weight, :integer
    end

    create_table :ar_members, :force => true do |t|
      t.string :name
      t.integer :member_type_id
    end

    create_table :ar_member_details, :force => true do |t|
      t.integer :member_id
      t.integer :organization_id
      t.string :extra_data
    end

    create_table :ar_memberships, :force => true do |t|
      t.datetime :joined_on
      t.integer :club_id, :member_id
      t.boolean :favourite, :default => false
      t.string :type
    end

    create_table :ar_member_types, :force => true do |t|
      t.string :name
    end

    create_table :ar_minivans, :force => true, :id => false do |t|
      t.string :minivan_id
      t.string :name
      t.string :speedometer_id
      t.string :color
    end

    create_table :ar_minimalistics, :force => true do |t|
    end

    create_table :ar_mixed_case_monkeys, :force => true, :id => false do |t|
      t.primary_key :monkeyID
      t.integer     :fleaCount
    end

    create_table :ar_mixins, :force => true do |t|
      t.integer  :parent_id
      t.integer  :pos
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :lft
      t.integer  :rgt
      t.integer  :root_id
      t.string   :type
    end

    create_table :ar_movies, :force => true, :id => false do |t|
      t.primary_key :movieid
      t.string      :name
    end

    create_table :ar_numeric_data, :force => true do |t|
      t.decimal :bank_balance, :precision => 10, :scale => 2
      t.decimal :big_bank_balance, :precision => 15, :scale => 2
      t.decimal :world_population, :precision => 10, :scale => 0
      t.decimal :my_house_population, :precision => 2, :scale => 0
      t.decimal :decimal_number_with_default, :precision => 3, :scale => 2, :default => 2.78
      t.float   :temperature
      #t.decimal :atoms_in_universe, :precision => 55, :scale => 0
      # Teradata only supports 38
      t.decimal :atoms_in_universe, :precision => 38, :scale => 0
    end

    create_table :ar_orders, :force => true do |t|
      t.string  :name
      t.integer :billing_customer_id
      t.integer :shipping_customer_id
    end

    create_table :ar_organizations, :force => true do |t|
      t.string :name
    end

    create_table :ar_owners, :primary_key => :owner_id ,:force => true do |t|
      t.string :name
      t.column :updated_at, :datetime
      t.column :happy_at,   :datetime
      t.string :essay_id
    end

    create_table :ar_paint_colors, :force => true do |t|
      t.integer :non_poly_one_id
    end

    create_table :ar_paint_textures, :force => true do |t|
      t.integer :non_poly_two_id
    end

    create_table :ar_parrots, :force => true do |t|
      t.column :name, :string
      t.column :parrot_sti_class, :string
      t.column :killer_id, :integer
      t.column :created_at, :datetime
      t.column :created_on, :datetime
      t.column :updated_at, :datetime
      t.column :updated_on, :datetime
    end

    create_table :ar_parrots_pirates, :id => false, :force => true do |t|
      t.column :parrot_id, :integer
      t.column :pirate_id, :integer
    end

    create_table :ar_parrots_treasures, :id => false, :force => true do |t|
      t.column :parrot_id, :integer
      t.column :treasure_id, :integer
    end

    create_table :ar_people, :force => true do |t|
      t.string     :first_name, :null => false
      t.references :primary_contact
      t.string     :gender, :limit => 1
      t.references :number1_fan
      t.integer    :lock_version, :null => false, :default => 0
      t.string     :comments
      t.integer    :followers_count, :default => 0
      t.references :best_friend
      t.references :best_friend_of
      t.integer    :insures, :null => false, :default => 0
      t.timestamps
    end

    create_table :ar_peoples_treasures, :id => false, :force => true do |t|
      t.column :rich_person_id, :integer
      t.column :treasure_id, :integer
    end

    create_table :ar_pets, :primary_key => :pet_id ,:force => true do |t|
      t.string :name
      t.integer :owner_id, :integer
      t.timestamps
    end

    create_table :ar_pirates, :force => true do |t|
      t.column :catchphrase, :string
      t.column :parrot_id, :integer
      t.integer :non_validated_parrot_id
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end

    create_table :ar_posts, :force => true do |t|
      t.integer :author_id
      t.string  :title, :null => false
      t.text    :body, :null => false
      t.string  :type
      t.integer :comments_count, :default => 0
      t.integer :taggings_count, :default => 0
      t.integer :taggings_with_delete_all_count, :default => 0
      t.integer :taggings_with_destroy_count, :default => 0
      t.integer :tags_count, :default => 0
      t.integer :tags_with_destroy_count, :default => 0
      t.integer :tags_with_nullify_count, :default => 0
    end

    create_table :ar_price_estimates, :force => true do |t|
      t.string :estimate_of_type
      t.integer :estimate_of_id
      t.integer :price
    end

    create_table :ar_products, :force => true do |t|
      t.references :collection
      t.string     :name
    end

    create_table :ar_projects, :force => true do |t|
      t.string :name
      t.string :type
    end

    create_table :ar_ratings, :force => true do |t|
      t.integer :comment_id
      t.integer :value
    end

    create_table :ar_readers, :force => true do |t|
      t.integer :post_id, :null => false
      t.integer :person_id, :null => false
      t.boolean :skimmer, :default => false
    end

    create_table :ar_references, :force => true do |t|
      t.integer :person_id
      t.integer :job_id
      t.boolean :favourite
      t.integer :lock_version, :default => 0
    end

    create_table :ar_shape_expressions, :force => true do |t|
      t.string  :paint_type
      t.integer :paint_id
      t.string  :shape_type
      t.integer :shape_id
    end

    create_table :ar_ships, :force => true do |t|
      t.string :name
      t.integer :pirate_id
      t.integer :update_only_pirate_id
      t.datetime :created_at
      t.datetime :created_on
      t.datetime :updated_at
      t.datetime :updated_on
    end

    create_table :ar_ship_parts, :force => true do |t|
      t.string :name
      t.integer :ship_id
    end

    create_table :ar_speedometers, :force => true, :id => false do |t|
      t.string :speedometer_id
      t.string :name
      t.string :dashboard_id
    end

    create_table :ar_sponsors, :force => true do |t|
      t.integer :club_id
      t.integer :sponsorable_id
      t.string :sponsorable_type
    end

    create_table :ar_string_key_objects, :id => false, :primary_key => :id, :force => true do |t|
      t.string     :id
      t.string     :name
      t.integer    :lock_version, :null => false, :default => 0
    end

    create_table :ar_students, :force => true do |t|
      t.string :name
    end

    create_table :ar_subscribers, :force => true, :id => false do |t|
      t.string :nick, :null => false
      t.string :name
      t.column :books_count, :integer, :null => false, :default => 0
    end
    add_index :ar_subscribers, :nick, :unique => true

    create_table :ar_subscriptions, :force => true do |t|
      t.string :subscriber_id
      t.integer :book_id
    end

    create_table :ar_tags, :force => true do |t|
      t.column :name, :string
      t.column :taggings_count, :integer, :default => 0
    end

    create_table :ar_taggings, :force => true do |t|
      t.column :tag_id, :integer
      t.column :super_tag_id, :integer
      t.column :taggable_type, :string
      t.column :taggable_id, :integer
      t.string :comment
    end

    create_table :ar_tasks, :force => true do |t|
      t.datetime :starting
      t.datetime :ending
    end

    create_table :ar_topics, :force => true do |t|
      t.string   :title
      t.string   :author_name
      t.string   :author_email_address
      t.datetime :written_on
      t.time     :bonus_time
      t.date     :last_read
      t.text     :content
      t.text     :important
      t.boolean  :approved, :default => true
      t.integer  :replies_count, :default => 0
      t.integer  :parent_id
      t.string   :parent_title
      t.string   :type
      t.string   :group
      t.timestamps
    end

    create_table :ar_toys, :primary_key => :toy_id ,:force => true do |t|
      t.string :name
      t.integer :pet_id, :integer
      t.timestamps
    end

    create_table :ar_traffic_lights, :force => true do |t|
      t.string   :location
      t.string   :state
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :ar_treasures, :force => true do |t|
      t.column :name, :string
      t.column :looter_id, :integer
      t.column :looter_type, :string
    end

    create_table :ar_tyres, :force => true do |t|
      t.integer :car_id
    end

    create_table :ar_variants, :force => true do |t|
      t.references :product
      t.string     :name
    end

    create_table :ar_vertices, :force => true do |t|
      t.column :label, :string
    end

    create_table 'warehouse-things', :force => true do |t|
      t.integer :value
    end

    [:circles, :squares, :triangles, :non_poly_ones, :non_poly_twos].each do |t|
      create_table(t, :force => true) { }
    end

    # NOTE - the following 4 tables are used by models that have :inverse_of options on the associations
    create_table :ar_men, :force => true do |t|
      t.string  :name
    end

    create_table :ar_faces, :force => true do |t|
      t.string  :description
      t.integer :man_id
      t.integer :polymorphic_man_id
      t.string  :polymorphic_man_type
      t.integer :horrible_polymorphic_man_id
      t.string  :horrible_polymorphic_man_type
    end

    create_table :ar_interests, :force => true do |t|
      t.string :topic
      t.integer :man_id
      t.integer :polymorphic_man_id
      t.string :polymorphic_man_type
      t.integer :zine_id
    end

    create_table :ar_wheels, :force => true do |t|
      t.references :wheelable, :polymorphic => true
    end

    create_table :ar_zines, :force => true do |t|
      t.string :title
    end

    create_table :ar_countries, :force => true, :id => false, :primary_key => 'country_id' do |t|
      t.string :country_id
      t.string :name
    end
    create_table :ar_treaties, :force => true, :id => false, :primary_key => 'treaty_id' do |t|
      t.string :treaty_id
      t.string :name
    end
    create_table :ar_countries_treaties, :force => true, :id => false do |t|
      t.string :country_id, :null => false
      t.string :treaty_id, :null => false
    end

    create_table :ar_liquid, :force => true do |t|
      t.string :name
    end
    create_table :ar_molecules, :force => true do |t|
      t.integer :liquid_id
      t.string :name
    end
    create_table :ar_electrons, :force => true do |t|
      t.integer :molecule_id
      t.string :name
    end
    create_table :ar_weirds, :force => true do |t|
      t.string 'a$b'
    end

    # fk_test_has_fk should be before fk_test_has_pk
    create_table :ar_fk_test_has_fk, :force => true do |t|
      t.integer :fk_id, :null => false
    end

    create_table :ar_fk_test_has_pk, :force => true do |t|
    end
  end
end
