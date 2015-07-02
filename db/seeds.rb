#encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
TargetOrganization.create(target_organization_name: "Департамент здравоохранения Пензенской области")
TargetOrganization.create(target_organization_name: "Департамент здравоохранения Московской области")
InstitutionAchievement.create(campaign_id: 3, name: "Аттестат о среднем общем образовании с отличием", max_value: 10, id_category: 9)
EntranceTestItem.create(competitive_group_id: 5, entrance_test_type_id: 1, form: "ЕГЭ", min_score: 36, entrance_test_priority: 1, subject_id: 11)
EntranceTestItem.create(competitive_group_id: 5, entrance_test_type_id: 1, form: "ЕГЭ", min_score: 36, entrance_test_priority: 2, subject_id: 4)
EntranceTestItem.create(competitive_group_id: 5, entrance_test_type_id: 1, form: "ЕГЭ", min_score: 36, entrance_test_priority: 3, subject_id: 1)
CompetitiveGroup.find(5).update_attributes(name: "Специалитет 2015")