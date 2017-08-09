# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170705134348) do

  create_table "announcements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "text",       limit: 65535
    t.date     "show_until"
    t.boolean  "active",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["show_until", "active"], name: "index_announcements_on_show_until_and_active", using: :btree
  end

  create_table "attachable_journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "journal_id",                 null: false
    t.integer "attachment_id",              null: false
    t.string  "filename",      default: "", null: false
    t.index ["attachment_id"], name: "index_attachable_journals_on_attachment_id", using: :btree
    t.index ["journal_id"], name: "index_attachable_journals_on_journal_id", using: :btree
  end

  create_table "attachment_journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "journal_id",                                null: false
    t.integer "container_id",                 default: 0,  null: false
    t.string  "container_type", limit: 30,    default: "", null: false
    t.string  "filename",                     default: "", null: false
    t.string  "disk_filename",                default: "", null: false
    t.integer "filesize",                     default: 0,  null: false
    t.string  "content_type",                 default: ""
    t.string  "digest",         limit: 40,    default: "", null: false
    t.integer "downloads",                    default: 0,  null: false
    t.integer "author_id",                    default: 0,  null: false
    t.text    "description",    limit: 65535
    t.index ["journal_id"], name: "index_attachment_journals_on_journal_id", using: :btree
  end

  create_table "attachments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "container_id",              default: 0,  null: false
    t.string   "container_type", limit: 30, default: "", null: false
    t.string   "filename",                  default: "", null: false
    t.string   "disk_filename",             default: "", null: false
    t.integer  "filesize",                  default: 0,  null: false
    t.string   "content_type",              default: ""
    t.string   "digest",         limit: 40, default: "", null: false
    t.integer  "downloads",                 default: 0,  null: false
    t.integer  "author_id",                 default: 0,  null: false
    t.datetime "created_on"
    t.string   "description"
    t.string   "file"
    t.index ["author_id"], name: "index_attachments_on_author_id", using: :btree
    t.index ["container_id", "container_type"], name: "index_attachments_on_container_id_and_container_type", using: :btree
    t.index ["created_on"], name: "index_attachments_on_created_on", using: :btree
  end

  create_table "attribute_help_texts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "help_text",      limit: 65535, null: false
    t.string   "type",                         null: false
    t.string   "attribute_name",               null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "auth_sources", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "type",              limit: 30, default: "",    null: false
    t.string  "name",              limit: 60, default: "",    null: false
    t.string  "host",              limit: 60
    t.integer "port"
    t.string  "account"
    t.string  "account_password",             default: ""
    t.string  "base_dn"
    t.string  "attr_login",        limit: 30
    t.string  "attr_firstname",    limit: 30
    t.string  "attr_lastname",     limit: 30
    t.string  "attr_mail",         limit: 30
    t.boolean "onthefly_register",            default: false, null: false
    t.boolean "tls",                          default: false, null: false
    t.string  "attr_admin"
    t.index ["id", "type"], name: "index_auth_sources_on_id_and_type", using: :btree
  end

  create_table "available_project_statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "project_type_id"
    t.integer  "reported_project_status_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_type_id"], name: "index_available_project_statuses_on_project_type_id", using: :btree
    t.index ["reported_project_status_id"], name: "index_avail_project_statuses_on_rep_project_status_id", using: :btree
  end

  create_table "boards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "project_id",                   null: false
    t.string  "name",            default: "", null: false
    t.string  "description"
    t.integer "position",        default: 1
    t.integer "topics_count",    default: 0,  null: false
    t.integer "messages_count",  default: 0,  null: false
    t.integer "last_message_id"
    t.index ["last_message_id"], name: "index_boards_on_last_message_id", using: :btree
    t.index ["project_id"], name: "boards_project_id", using: :btree
  end

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "project_id",                 default: 0,  null: false
    t.string  "name",           limit: 256, default: "", null: false
    t.integer "assigned_to_id"
    t.index ["assigned_to_id"], name: "index_categories_on_assigned_to_id", using: :btree
    t.index ["project_id"], name: "issue_categories_project_id", using: :btree
  end

  create_table "changes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "changeset_id",                             null: false
    t.string  "action",        limit: 1,     default: "", null: false
    t.text    "path",          limit: 65535,              null: false
    t.text    "from_path",     limit: 65535
    t.string  "from_revision"
    t.string  "revision"
    t.string  "branch"
    t.index ["changeset_id"], name: "changesets_changeset_id", using: :btree
  end

  create_table "changeset_journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "journal_id",                  null: false
    t.integer  "repository_id",               null: false
    t.string   "revision",                    null: false
    t.string   "committer"
    t.datetime "committed_on",                null: false
    t.text     "comments",      limit: 65535
    t.date     "commit_date"
    t.string   "scmid"
    t.integer  "user_id"
    t.index ["journal_id"], name: "index_changeset_journals_on_journal_id", using: :btree
  end

  create_table "changesets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "repository_id",               null: false
    t.string   "revision",                    null: false
    t.string   "committer"
    t.datetime "committed_on",                null: false
    t.text     "comments",      limit: 65535
    t.date     "commit_date"
    t.string   "scmid"
    t.integer  "user_id"
    t.index ["committed_on"], name: "index_changesets_on_committed_on", using: :btree
    t.index ["repository_id", "committed_on"], name: "index_changesets_on_repository_id_and_committed_on", using: :btree
    t.index ["repository_id", "revision"], name: "changesets_repos_rev", unique: true, using: :btree
    t.index ["repository_id", "scmid"], name: "changesets_repos_scmid", using: :btree
    t.index ["repository_id"], name: "index_changesets_on_repository_id", using: :btree
    t.index ["user_id"], name: "index_changesets_on_user_id", using: :btree
  end

  create_table "changesets_work_packages", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "changeset_id",    null: false
    t.integer "work_package_id", null: false
    t.index ["changeset_id", "work_package_id"], name: "changesets_work_packages_ids", unique: true, using: :btree
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "commented_type", limit: 30,    default: "", null: false
    t.integer  "commented_id",                 default: 0,  null: false
    t.integer  "author_id",                    default: 0,  null: false
    t.text     "comments",       limit: 65535
    t.datetime "created_on",                                null: false
    t.datetime "updated_on",                                null: false
    t.index ["author_id"], name: "index_comments_on_author_id", using: :btree
    t.index ["commented_id", "commented_type"], name: "index_comments_on_commented_id_and_commented_type", using: :btree
  end

  create_table "custom_fields", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "type",          limit: 30,    default: "",    null: false
    t.string   "field_format",  limit: 30,    default: "",    null: false
    t.string   "regexp",                      default: ""
    t.integer  "min_length",                  default: 0,     null: false
    t.integer  "max_length",                  default: 0,     null: false
    t.boolean  "is_required",                 default: false, null: false
    t.boolean  "is_for_all",                  default: false, null: false
    t.boolean  "is_filter",                   default: false, null: false
    t.integer  "position",                    default: 1
    t.boolean  "searchable",                  default: false
    t.boolean  "editable",                    default: true
    t.boolean  "visible",                     default: true,  null: false
    t.boolean  "multi_value",                 default: false
    t.text     "default_value", limit: 65535
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["id", "type"], name: "index_custom_fields_on_id_and_type", using: :btree
  end

  create_table "custom_fields_projects", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "custom_field_id", default: 0, null: false
    t.integer "project_id",      default: 0, null: false
    t.index ["custom_field_id", "project_id"], name: "index_custom_fields_projects_on_custom_field_id_and_project_id", using: :btree
  end

  create_table "custom_fields_types", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "custom_field_id", default: 0, null: false
    t.integer "type_id",         default: 0, null: false
    t.index ["custom_field_id", "type_id"], name: "custom_fields_types_unique", unique: true, using: :btree
  end

  create_table "custom_options", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "custom_field_id"
    t.integer  "position"
    t.boolean  "default_value"
    t.text     "value",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_styles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "favicon"
    t.string   "touch_icon"
  end

  create_table "custom_values", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "customized_type", limit: 30,    default: "", null: false
    t.integer "customized_id",                 default: 0,  null: false
    t.integer "custom_field_id",               default: 0,  null: false
    t.text    "value",           limit: 65535
    t.index ["custom_field_id"], name: "index_custom_values_on_custom_field_id", using: :btree
    t.index ["customized_type", "customized_id"], name: "custom_values_customized", using: :btree
  end

  create_table "customizable_journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "journal_id",                    null: false
    t.integer "custom_field_id",               null: false
    t.text    "value",           limit: 65535
    t.index ["custom_field_id"], name: "index_customizable_journals_on_custom_field_id", using: :btree
    t.index ["journal_id"], name: "index_customizable_journals_on_journal_id", using: :btree
  end

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "priority",                 default: 0
    t.integer  "attempts",                 default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "design_colors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "variable"
    t.string   "hexcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["variable"], name: "index_design_colors_on_variable", unique: true, using: :btree
  end

  create_table "enabled_modules", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "project_id"
    t.string  "name",       null: false
    t.index ["name"], name: "index_enabled_modules_on_name", length: { name: 8 }, using: :btree
    t.index ["project_id"], name: "enabled_modules_project_id", using: :btree
  end

  create_table "enterprise_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "encoded_token", limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "enumerations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name",       limit: 30, default: "",    null: false
    t.integer "position",              default: 1
    t.boolean "is_default",            default: false, null: false
    t.string  "type"
    t.boolean "active",                default: true,  null: false
    t.integer "project_id"
    t.integer "parent_id"
    t.index ["id", "type"], name: "index_enumerations_on_id_and_type", using: :btree
    t.index ["project_id"], name: "index_enumerations_on_project_id", using: :btree
  end

  create_table "group_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "group_id", null: false
    t.integer "user_id",  null: false
    t.index ["group_id", "user_id"], name: "group_user_ids", unique: true, using: :btree
  end

  create_table "journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "journable_type"
    t.integer  "journable_id"
    t.integer  "user_id",                      default: 0, null: false
    t.text     "notes",          limit: 65535
    t.datetime "created_at",                               null: false
    t.integer  "version",                      default: 0, null: false
    t.string   "activity_type"
    t.index ["activity_type"], name: "index_journals_on_activity_type", using: :btree
    t.index ["created_at"], name: "index_journals_on_created_at", using: :btree
    t.index ["journable_id"], name: "index_journals_on_journable_id", using: :btree
    t.index ["journable_type", "journable_id", "version"], name: "index_journals_on_journable_type_and_journable_id_and_version", unique: true, using: :btree
    t.index ["journable_type"], name: "index_journals_on_journable_type", using: :btree
    t.index ["user_id"], name: "index_journals_on_user_id", using: :btree
  end

  create_table "member_roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "member_id",      null: false
    t.integer "role_id",        null: false
    t.integer "inherited_from"
    t.index ["inherited_from"], name: "index_member_roles_on_inherited_from", using: :btree
    t.index ["member_id"], name: "index_member_roles_on_member_id", using: :btree
    t.index ["role_id"], name: "index_member_roles_on_role_id", using: :btree
  end

  create_table "members", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",           default: 0,     null: false
    t.integer  "project_id",        default: 0,     null: false
    t.datetime "created_on"
    t.boolean  "mail_notification", default: false, null: false
    t.index ["project_id"], name: "index_members_on_project_id", using: :btree
    t.index ["user_id", "project_id"], name: "index_members_on_user_id_and_project_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_members_on_user_id", using: :btree
  end

  create_table "menu_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name"
    t.string  "title"
    t.integer "parent_id"
    t.text    "options",        limit: 65535
    t.integer "navigatable_id"
    t.string  "type"
    t.index ["navigatable_id", "title"], name: "index_menu_items_on_navigatable_id_and_title", using: :btree
    t.index ["parent_id"], name: "index_menu_items_on_parent_id", using: :btree
  end

  create_table "message_journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "journal_id",                                  null: false
    t.integer "board_id",                                    null: false
    t.integer "parent_id"
    t.string  "subject",                     default: "",    null: false
    t.text    "content",       limit: 65535
    t.integer "author_id"
    t.integer "replies_count",               default: 0,     null: false
    t.integer "last_reply_id"
    t.boolean "locked",                      default: false
    t.integer "sticky",                      default: 0
    t.index ["journal_id"], name: "index_message_journals_on_journal_id", using: :btree
  end

  create_table "messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "board_id",                                    null: false
    t.integer  "parent_id"
    t.string   "subject",                     default: "",    null: false
    t.text     "content",       limit: 65535
    t.integer  "author_id"
    t.integer  "replies_count",               default: 0,     null: false
    t.integer  "last_reply_id"
    t.datetime "created_on",                                  null: false
    t.datetime "updated_on",                                  null: false
    t.boolean  "locked",                      default: false
    t.integer  "sticky",                      default: 0
    t.datetime "sticked_on"
    t.index ["author_id"], name: "index_messages_on_author_id", using: :btree
    t.index ["board_id", "updated_on"], name: "index_messages_on_board_id_and_updated_on", using: :btree
    t.index ["board_id"], name: "messages_board_id", using: :btree
    t.index ["created_on"], name: "index_messages_on_created_on", using: :btree
    t.index ["last_reply_id"], name: "index_messages_on_last_reply_id", using: :btree
    t.index ["parent_id"], name: "messages_parent_id", using: :btree
  end

  create_table "news", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "project_id"
    t.string   "title",          limit: 60,    default: "", null: false
    t.string   "summary",                      default: ""
    t.text     "description",    limit: 65535
    t.integer  "author_id",                    default: 0,  null: false
    t.datetime "created_on"
    t.integer  "comments_count",               default: 0,  null: false
    t.index ["author_id"], name: "index_news_on_author_id", using: :btree
    t.index ["created_on"], name: "index_news_on_created_on", using: :btree
    t.index ["project_id", "created_on"], name: "index_news_on_project_id_and_created_on", using: :btree
    t.index ["project_id"], name: "news_project_id", using: :btree
  end

  create_table "news_journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "journal_id",                                null: false
    t.integer "project_id"
    t.string  "title",          limit: 60,    default: "", null: false
    t.string  "summary",                      default: ""
    t.text    "description",    limit: 65535
    t.integer "author_id",                    default: 0,  null: false
    t.integer "comments_count",               default: 0,  null: false
    t.index ["journal_id"], name: "index_news_journals_on_journal_id", using: :btree
  end

  create_table "planning_element_type_colors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                   null: false
    t.string   "hexcode",                null: false
    t.integer  "position",   default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_associations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "project_a_id"
    t.integer  "project_b_id"
    t.text     "description",  limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_a_id"], name: "index_project_associations_on_project_a_id", using: :btree
    t.index ["project_b_id"], name: "index_project_associations_on_project_b_id", using: :btree
  end

  create_table "project_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",               default: "",   null: false
    t.boolean  "allows_association", default: true, null: false
    t.integer  "position",           default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                                       default: "",   null: false
    t.text     "description",                  limit: 65535
    t.boolean  "is_public",                                  default: true, null: false
    t.integer  "parent_id"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "identifier"
    t.integer  "status",                                     default: 1,    null: false
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "project_type_id"
    t.integer  "responsible_id"
    t.integer  "work_packages_responsible_id"
    t.index ["identifier"], name: "index_projects_on_identifier", using: :btree
    t.index ["lft"], name: "index_projects_on_lft", using: :btree
    t.index ["project_type_id"], name: "index_projects_on_project_type_id", using: :btree
    t.index ["responsible_id"], name: "index_projects_on_responsible_id", using: :btree
    t.index ["rgt"], name: "index_projects_on_rgt", using: :btree
    t.index ["work_packages_responsible_id"], name: "index_projects_on_work_packages_responsible_id", using: :btree
  end

  create_table "projects_types", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "project_id", default: 0, null: false
    t.integer "type_id",    default: 0, null: false
    t.index ["project_id", "type_id"], name: "projects_types_unique", unique: true, using: :btree
    t.index ["project_id"], name: "projects_types_project_id", using: :btree
  end

  create_table "queries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "project_id"
    t.string  "name",                              default: "",    null: false
    t.text    "filters",             limit: 65535
    t.integer "user_id",                           default: 0,     null: false
    t.boolean "is_public",                         default: false, null: false
    t.text    "column_names",        limit: 65535
    t.text    "sort_criteria",       limit: 65535
    t.string  "group_by"
    t.boolean "display_sums",                      default: false, null: false
    t.boolean "timeline_visible",                  default: false
    t.boolean "show_hierarchies",                  default: false
    t.integer "timeline_zoom_level",               default: 0
    t.index ["project_id"], name: "index_queries_on_project_id", using: :btree
    t.index ["user_id"], name: "index_queries_on_user_id", using: :btree
  end

  create_table "relations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "from_id",                                  null: false
    t.integer "to_id",                                    null: false
    t.string  "relation_type",               default: "", null: false
    t.integer "delay"
    t.text    "description",   limit: 65535
    t.index ["from_id"], name: "index_relations_on_from_id", using: :btree
    t.index ["to_id"], name: "index_relations_on_to_id", using: :btree
  end

  create_table "reportings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "reported_project_status_comment", limit: 65535
    t.integer  "project_id"
    t.integer  "reporting_to_project_id"
    t.integer  "reported_project_status_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], name: "index_reportings_on_project_id", using: :btree
    t.index ["reported_project_status_id"], name: "index_reportings_on_reported_project_status_id", using: :btree
    t.index ["reporting_to_project_id"], name: "index_reportings_on_reporting_to_project_id", using: :btree
  end

  create_table "repositories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "project_id",                        default: 0,  null: false
    t.string   "url",                               default: "", null: false
    t.string   "login",                  limit: 60, default: ""
    t.string   "password",                          default: ""
    t.string   "root_url",                          default: ""
    t.string   "type"
    t.string   "path_encoding",          limit: 64
    t.string   "log_encoding",           limit: 64
    t.string   "scm_type",                                       null: false
    t.bigint   "required_storage_bytes",            default: 0,  null: false
    t.datetime "storage_updated_at"
    t.index ["project_id"], name: "index_repositories_on_project_id", using: :btree
  end

  create_table "role_permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "permission"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_role_permissions_on_role_id", using: :btree
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name",       limit: 30, default: "",   null: false
    t.integer "position",              default: 1
    t.boolean "assignable",            default: true
    t.integer "builtin",               default: 0,    null: false
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "session_id",               null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.index ["session_id"], name: "index_sessions_on_session_id", using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                     default: "", null: false
    t.text     "value",      limit: 65535
    t.datetime "updated_on"
    t.index ["name"], name: "index_settings_on_name", using: :btree
  end

  create_table "statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name",               limit: 30, default: "",    null: false
    t.boolean "is_closed",                     default: false, null: false
    t.boolean "is_default",                    default: false, null: false
    t.integer "position",                      default: 1
    t.integer "default_done_ratio"
    t.index ["is_closed"], name: "index_statuses_on_is_closed", using: :btree
    t.index ["is_default"], name: "index_statuses_on_is_default", using: :btree
    t.index ["position"], name: "index_statuses_on_position", using: :btree
  end

  create_table "time_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "project_id",                 null: false
    t.integer  "user_id",                    null: false
    t.integer  "work_package_id"
    t.float    "hours",           limit: 24, null: false
    t.string   "comments"
    t.integer  "activity_id",                null: false
    t.date     "spent_on",                   null: false
    t.integer  "tyear",                      null: false
    t.integer  "tmonth",                     null: false
    t.integer  "tweek",                      null: false
    t.datetime "created_on",                 null: false
    t.datetime "updated_on",                 null: false
    t.index ["activity_id"], name: "index_time_entries_on_activity_id", using: :btree
    t.index ["created_on"], name: "index_time_entries_on_created_on", using: :btree
    t.index ["project_id", "updated_on"], name: "index_time_entries_on_project_id_and_updated_on", using: :btree
    t.index ["project_id"], name: "time_entries_project_id", using: :btree
    t.index ["user_id"], name: "index_time_entries_on_user_id", using: :btree
    t.index ["work_package_id"], name: "time_entries_issue_id", using: :btree
  end

  create_table "time_entry_journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "journal_id",                 null: false
    t.integer "project_id",                 null: false
    t.integer "user_id",                    null: false
    t.integer "work_package_id"
    t.float   "hours",           limit: 24, null: false
    t.string  "comments"
    t.integer "activity_id",                null: false
    t.date    "spent_on",                   null: false
    t.integer "tyear",                      null: false
    t.integer "tmonth",                     null: false
    t.integer "tweek",                      null: false
    t.index ["journal_id"], name: "index_time_entry_journals_on_journal_id", using: :btree
  end

  create_table "timelines", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                     null: false
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "options",    limit: 65535
    t.index ["project_id"], name: "index_timelines_on_project_id", using: :btree
  end

  create_table "tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",               default: 0,  null: false
    t.string   "action",     limit: 30, default: "", null: false
    t.string   "value",      limit: 40, default: "", null: false
    t.datetime "created_on",                         null: false
    t.index ["user_id"], name: "index_tokens_on_user_id", using: :btree
  end

  create_table "types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                           default: "",    null: false
    t.integer  "position",                       default: 1
    t.boolean  "is_in_roadmap",                  default: true,  null: false
    t.boolean  "in_aggregation",                 default: true,  null: false
    t.boolean  "is_milestone",                   default: false, null: false
    t.boolean  "is_default",                     default: false, null: false
    t.integer  "color_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "is_standard",                    default: false, null: false
    t.text     "attribute_groups", limit: 65535
    t.index ["color_id"], name: "index_types_on_color_id", using: :btree
  end

  create_table "user_passwords", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",                     null: false
    t.string   "hashed_password", limit: 128, null: false
    t.string   "salt",            limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                        null: false
    t.index ["user_id"], name: "index_user_passwords_on_user_id", using: :btree
  end

  create_table "user_preferences", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id",                 default: 0,     null: false
    t.text    "others",    limit: 65535
    t.boolean "hide_mail",               default: true
    t.string  "time_zone"
    t.boolean "impaired",                default: false
    t.index ["user_id"], name: "index_user_preferences_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "login",                 limit: 256, default: "",    null: false
    t.string   "firstname",             limit: 30,  default: "",    null: false
    t.string   "lastname",              limit: 30,  default: "",    null: false
    t.string   "mail",                  limit: 60,  default: "",    null: false
    t.boolean  "admin",                             default: false, null: false
    t.integer  "status",                            default: 1,     null: false
    t.datetime "last_login_on"
    t.string   "language",              limit: 5,   default: ""
    t.integer  "auth_source_id"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "type"
    t.string   "identity_url"
    t.string   "mail_notification",                 default: "",    null: false
    t.boolean  "first_login",                       default: true,  null: false
    t.boolean  "force_password_change",             default: false
    t.integer  "failed_login_count",                default: 0
    t.datetime "last_failed_login_on"
    t.index ["auth_source_id"], name: "index_users_on_auth_source_id", using: :btree
    t.index ["id", "type"], name: "index_users_on_id_and_type", using: :btree
    t.index ["type", "login"], name: "index_users_on_type_and_login", length: { login: 255 }, using: :btree
    t.index ["type", "status"], name: "index_users_on_type_and_status", using: :btree
    t.index ["type"], name: "index_users_on_type", using: :btree
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "project_id",      default: 0,      null: false
    t.string   "name",            default: "",     null: false
    t.string   "description",     default: ""
    t.date     "effective_date"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "wiki_page_title"
    t.string   "status",          default: "open"
    t.string   "sharing",         default: "none", null: false
    t.date     "start_date"
    t.index ["project_id"], name: "versions_project_id", using: :btree
    t.index ["sharing"], name: "index_versions_on_sharing", using: :btree
  end

  create_table "watchers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "watchable_type", default: "", null: false
    t.integer "watchable_id",   default: 0,  null: false
    t.integer "user_id"
    t.index ["user_id", "watchable_type"], name: "watchers_user_id_type", using: :btree
    t.index ["user_id"], name: "index_watchers_on_user_id", using: :btree
    t.index ["watchable_id", "watchable_type"], name: "index_watchers_on_watchable_id_and_watchable_type", using: :btree
  end

  create_table "wiki_content_journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "journal_id",                    null: false
    t.integer "page_id",                       null: false
    t.integer "author_id"
    t.text    "text",       limit: 4294967295
    t.index ["journal_id"], name: "index_wiki_content_journals_on_journal_id", using: :btree
  end

  create_table "wiki_content_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "wiki_content_id",                                 null: false
    t.integer  "page_id",                                         null: false
    t.integer  "author_id"
    t.binary   "data",            limit: 4294967295
    t.string   "compression",     limit: 6,          default: ""
    t.string   "comments",                           default: ""
    t.datetime "updated_on",                                      null: false
    t.integer  "version",                                         null: false
    t.index ["updated_on"], name: "index_wiki_content_versions_on_updated_on", using: :btree
    t.index ["wiki_content_id"], name: "wiki_content_versions_wcid", using: :btree
  end

  create_table "wiki_contents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "page_id",                         null: false
    t.integer  "author_id"
    t.text     "text",         limit: 4294967295
    t.datetime "updated_on",                      null: false
    t.integer  "lock_version",                    null: false
    t.index ["author_id"], name: "index_wiki_contents_on_author_id", using: :btree
    t.index ["page_id", "updated_on"], name: "index_wiki_contents_on_page_id_and_updated_on", using: :btree
    t.index ["page_id"], name: "wiki_contents_page_id", using: :btree
  end

  create_table "wiki_pages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "wiki_id",                    null: false
    t.string   "title",                      null: false
    t.datetime "created_on",                 null: false
    t.boolean  "protected",  default: false, null: false
    t.integer  "parent_id"
    t.string   "slug",                       null: false
    t.index ["parent_id"], name: "index_wiki_pages_on_parent_id", using: :btree
    t.index ["wiki_id", "slug"], name: "wiki_pages_wiki_id_slug", unique: true, using: :btree
    t.index ["wiki_id", "title"], name: "wiki_pages_wiki_id_title", using: :btree
    t.index ["wiki_id"], name: "index_wiki_pages_on_wiki_id", using: :btree
  end

  create_table "wiki_redirects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "wiki_id",      null: false
    t.string   "title"
    t.string   "redirects_to"
    t.datetime "created_on",   null: false
    t.index ["wiki_id", "title"], name: "wiki_redirects_wiki_id_title", using: :btree
    t.index ["wiki_id"], name: "index_wiki_redirects_on_wiki_id", using: :btree
  end

  create_table "wikis", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "project_id",             null: false
    t.string  "start_page",             null: false
    t.integer "status",     default: 1, null: false
    t.index ["project_id"], name: "wikis_project_id", using: :btree
  end

  create_table "work_package_journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "journal_id",                                  null: false
    t.integer "type_id",                        default: 0,  null: false
    t.integer "project_id",                     default: 0,  null: false
    t.string  "subject",                        default: "", null: false
    t.text    "description",      limit: 65535
    t.date    "due_date"
    t.integer "category_id"
    t.integer "status_id",                      default: 0,  null: false
    t.integer "assigned_to_id"
    t.integer "priority_id",                    default: 0,  null: false
    t.integer "fixed_version_id"
    t.integer "author_id",                      default: 0,  null: false
    t.integer "done_ratio",                     default: 0,  null: false
    t.float   "estimated_hours",  limit: 24
    t.date    "start_date"
    t.integer "parent_id"
    t.integer "responsible_id"
    t.index ["journal_id"], name: "index_work_package_journals_on_journal_id", using: :btree
  end

  create_table "work_packages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "type_id",                        default: 0,  null: false
    t.integer  "project_id",                     default: 0,  null: false
    t.string   "subject",                        default: "", null: false
    t.text     "description",      limit: 65535
    t.date     "due_date"
    t.integer  "category_id"
    t.integer  "status_id",                      default: 0,  null: false
    t.integer  "assigned_to_id"
    t.integer  "priority_id",                    default: 0
    t.integer  "fixed_version_id"
    t.integer  "author_id",                      default: 0,  null: false
    t.integer  "lock_version",                   default: 0,  null: false
    t.integer  "done_ratio",                     default: 0,  null: false
    t.float    "estimated_hours",  limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.integer  "parent_id"
    t.integer  "responsible_id"
    t.integer  "root_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.index ["assigned_to_id"], name: "index_work_packages_on_assigned_to_id", using: :btree
    t.index ["author_id"], name: "index_work_packages_on_author_id", using: :btree
    t.index ["category_id"], name: "index_work_packages_on_category_id", using: :btree
    t.index ["created_at"], name: "index_work_packages_on_created_at", using: :btree
    t.index ["fixed_version_id"], name: "index_work_packages_on_fixed_version_id", using: :btree
    t.index ["parent_id"], name: "index_work_packages_on_parent_id", using: :btree
    t.index ["project_id", "updated_at"], name: "index_work_packages_on_project_id_and_updated_at", using: :btree
    t.index ["project_id"], name: "index_work_packages_on_project_id", using: :btree
    t.index ["responsible_id"], name: "index_work_packages_on_responsible_id", using: :btree
    t.index ["root_id", "lft", "rgt"], name: "index_work_packages_on_root_id_and_lft_and_rgt", using: :btree
    t.index ["status_id"], name: "index_work_packages_on_status_id", using: :btree
    t.index ["type_id"], name: "index_work_packages_on_type_id", using: :btree
    t.index ["updated_at"], name: "index_work_packages_on_updated_at", using: :btree
  end

  create_table "workflows", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "type_id",       default: 0,     null: false
    t.integer "old_status_id", default: 0,     null: false
    t.integer "new_status_id", default: 0,     null: false
    t.integer "role_id",       default: 0,     null: false
    t.boolean "assignee",      default: false, null: false
    t.boolean "author",        default: false, null: false
    t.index ["new_status_id"], name: "index_workflows_on_new_status_id", using: :btree
    t.index ["old_status_id"], name: "index_workflows_on_old_status_id", using: :btree
    t.index ["role_id", "type_id", "old_status_id"], name: "wkfs_role_type_old_status", using: :btree
    t.index ["role_id"], name: "index_workflows_on_role_id", using: :btree
  end

end
