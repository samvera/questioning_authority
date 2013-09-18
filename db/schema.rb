# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20130918141523) do

  create_table "mesh_trees", force: true do |t|
    t.string "term_id"
    t.string "tree_number"
  end

  add_index "mesh_trees", ["term_id"], name: "index_mesh_trees_on_term_id"
  add_index "mesh_trees", ["tree_number"], name: "index_mesh_trees_on_tree_number"

  create_table "subject_mesh_terms", force: true do |t|
    t.string "term_id"
    t.string "term"
    t.text   "synonyms"
    t.string "term_lower"
  end

  add_index "subject_mesh_terms", ["term_id"], name: "index_subject_mesh_terms_on_term_id"
  add_index "subject_mesh_terms", ["term_lower"], name: "index_subject_mesh_terms_on_term_lower"

end
